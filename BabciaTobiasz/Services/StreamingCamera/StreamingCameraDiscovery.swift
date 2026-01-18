//
//  StreamingCameraDiscovery.swift
//  BabciaTobiasz
//

import Foundation

enum StreamingCameraDiscoveryKind: String, CaseIterable, Identifiable {
    case rtsp
    case tapo
    case homeAssistant

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .rtsp:
            return String(localized: "cameraDiscovery.kind.rtsp")
        case .tapo:
            return String(localized: "cameraDiscovery.kind.tapo")
        case .homeAssistant:
            return String(localized: "cameraDiscovery.kind.homeAssistant")
        }
    }
}

struct StreamingCameraDiscoveryResult: Identifiable, Hashable {
    let id = UUID()
    let kind: StreamingCameraDiscoveryKind
    let name: String
    let host: String
    let port: Int?
    let serviceType: String
    let suggestedURL: URL?
}

@MainActor
@Observable
final class StreamingCameraDiscoveryHub: NSObject {
    var results: [StreamingCameraDiscoveryResult] = []
    var isScanning: Bool = false

    private struct ServiceEntry {
        let browser: NetServiceBrowser
        let kind: StreamingCameraDiscoveryKind
        let serviceType: String
    }

    private var entries: [ServiceEntry] = []
    private var browserKinds: [ObjectIdentifier: (StreamingCameraDiscoveryKind, String)] = [:]
    private var serviceKinds: [ObjectIdentifier: (StreamingCameraDiscoveryKind, String)] = [:]
    private var activeBrowsers: Int = 0

    func start() {
        guard !isScanning else { return }
        results = []
        entries = []
        browserKinds = [:]
        serviceKinds = [:]
        isScanning = true
        activeBrowsers = 0

        let serviceTypes: [(StreamingCameraDiscoveryKind, String)] = [
            (.tapo, "_tapo._tcp."),
            (.homeAssistant, "_home-assistant._tcp."),
            (.homeAssistant, "_homeassistant._tcp."),
            (.rtsp, "_rtsp._tcp.")
        ]

        for (kind, type) in serviceTypes {
            let browser = NetServiceBrowser()
            browser.delegate = self
            let entry = ServiceEntry(browser: browser, kind: kind, serviceType: type)
            entries.append(entry)
            browserKinds[ObjectIdentifier(browser)] = (kind, type)
            browser.searchForServices(ofType: type, inDomain: "local.")
            activeBrowsers += 1
        }
    }

    func stop() {
        guard isScanning else { return }
        entries.forEach { $0.browser.stop() }
        entries = []
        browserKinds = [:]
        serviceKinds = [:]
        activeBrowsers = 0
        isScanning = false
    }

    private func handleResolvedService(_ service: NetService) {
        let host = normalizeHost(service.hostName ?? service.name)
        let port = service.port > 0 ? service.port : nil
        guard let (kind, serviceType) = serviceKinds[ObjectIdentifier(service)] else { return }

        let suggestion = suggestedURL(for: kind, host: host, port: port, service: service)
        let entry = StreamingCameraDiscoveryResult(
            kind: kind,
            name: service.name,
            host: host,
            port: port,
            serviceType: serviceType,
            suggestedURL: suggestion
        )

        if results.contains(where: { $0.kind == entry.kind && $0.host == entry.host && $0.port == entry.port }) {
            return
        }
        results.append(entry)
    }

    private func suggestedURL(
        for kind: StreamingCameraDiscoveryKind,
        host: String,
        port: Int?,
        service: NetService
    ) -> URL? {
        switch kind {
        case .rtsp:
            let resolvedPort = port ?? 554
            return URL(string: "rtsp://\(host):\(resolvedPort)/")
        case .homeAssistant:
            let txt = parseTXT(service)
            if let base = txt["base_url"] ?? txt["api_base_url"], let url = URL(string: base) {
                return url
            }
            let scheme = (txt["ssl"] == "1" || txt["https"] == "1") ? "https" : "http"
            if let port {
                return URL(string: "\(scheme)://\(host):\(port)")
            }
            return URL(string: "\(scheme)://\(host)")
        case .tapo:
            return nil
        }
    }

    private func parseTXT(_ service: NetService) -> [String: String] {
        guard let data = service.txtRecordData() else { return [:] }
        let dict = NetService.dictionary(fromTXTRecord: data)
        var output: [String: String] = [:]
        for (key, value) in dict {
            if let stringValue = String(data: value, encoding: .utf8) {
                output[key] = stringValue
            }
        }
        return output
    }

    private func normalizeHost(_ host: String) -> String {
        if host.hasSuffix(".") {
            return String(host.dropLast())
        }
        return host
    }
}

extension StreamingCameraDiscoveryHub: NetServiceBrowserDelegate, NetServiceDelegate {
    nonisolated func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didFind service: NetService,
        moreComing: Bool
    ) {
        Task { @MainActor in
            guard let (kind, serviceType) = browserKinds[ObjectIdentifier(browser)] else { return }
            serviceKinds[ObjectIdentifier(service)] = (kind, serviceType)
            service.delegate = self
            service.resolve(withTimeout: 5)
        }
    }

    nonisolated func netServiceDidResolveAddress(_ sender: NetService) {
        Task { @MainActor in
            handleResolvedService(sender)
        }
    }

    nonisolated func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        Task { @MainActor in
            activeBrowsers = max(0, activeBrowsers - 1)
            if activeBrowsers == 0 {
                isScanning = false
            }
        }
    }
}
