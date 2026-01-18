//
//  TapoDiscoveryService.swift
//  BabciaTobiasz
//

import Foundation

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
        Task { @MainActor in
            services.append(service)
            service.delegate = self
            service.resolve(withTimeout: 5)
        }
    }

    nonisolated func netServiceDidResolveAddress(_ sender: NetService) {
        Task { @MainActor in
            let hostName = sender.hostName ?? sender.name
            let entry = DiscoveredService(
                name: sender.name,
                host: hostName,
                port: sender.port > 0 ? sender.port : nil
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
