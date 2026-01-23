//
//  TapoDiscoveryService.swift
//  BabciaTobiasz
//

@preconcurrency import Foundation

@MainActor
@Observable
final class TapoDiscoveryService: NSObject {
    struct DiscoveredService: Identifiable {
        let id = UUID()
        let name: String
        let host: String
        let port: Int?
    }

    var discovered: [DiscoveredService] = []
    var isScanning: Bool = false

    private let browser = NetServiceBrowser()
    private var services: [NetService] = []

    func start() {
        guard !isScanning else { return }
        discovered = []
        services = []
        isScanning = true
        browser.delegate = self
        browser.searchForServices(ofType: "_tapo._tcp.", inDomain: "local.")
    }

    func stop() {
        guard isScanning else { return }
        browser.stop()
        services.removeAll()
        isScanning = false
    }
}

extension TapoDiscoveryService: NetServiceBrowserDelegate, NetServiceDelegate {
    nonisolated func netServiceBrowser(
        _ browser: NetServiceBrowser,
        didFind service: NetService,
        moreComing: Bool
    ) {
        let serviceCopy = service
        Task { @MainActor [serviceCopy] in
            services.append(serviceCopy)
            serviceCopy.delegate = self
            serviceCopy.resolve(withTimeout: 5)
        }
    }

    nonisolated func netServiceDidResolveAddress(_ sender: NetService) {
        let name = sender.name
        let hostName = sender.hostName ?? sender.name
        let port = sender.port > 0 ? sender.port : nil
        Task { @MainActor in
            let entry = DiscoveredService(
                name: name,
                host: hostName,
                port: port
            )
            if !discovered.contains(where: { $0.host == entry.host && $0.port == entry.port }) {
                discovered.append(entry)
            }
        }
    }

    nonisolated func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        Task { @MainActor in
            isScanning = false
        }
    }
}
