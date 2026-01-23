//
//  StreamingCameraManager.swift
//  BabciaTobiasz
//

import Foundation
import SwiftData
import UIKit

@MainActor
@Observable
final class StreamingCameraManager {
    var configs: [StreamingCameraConfig] = []
    var errorMessage: String?

    private var store: StreamingCameraStore?
    private let credentialStore = StreamingCameraCredentialStore()

    func configure(modelContext: ModelContext) {
        store = StreamingCameraStore(modelContext: modelContext)
    }

    func loadConfigs() {
        guard let store else { return }
        do {
            configs = try store.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addCamera(_ config: StreamingCameraConfig, secret: String?) {
        guard let store else { return }
        do {
            if let secret, !secret.isEmpty {
                credentialStore.setSecret(secret, for: config)
            }
            try store.insert(config)
            configs = try store.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateCamera(_ config: StreamingCameraConfig, secret: String?) {
        guard let store else { return }
        do {
            if let secret {
                if secret.isEmpty {
                    credentialStore.deleteSecret(for: config)
                } else {
                    credentialStore.setSecret(secret, for: config)
                }
            }
            config.touchUpdatedAt()
            try store.save()
            configs = try store.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteCamera(_ config: StreamingCameraConfig) {
        guard let store else { return }
        do {
            credentialStore.deleteSecret(for: config)
            try store.delete(config)
            configs = try store.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func provider(for config: StreamingCameraConfig) throws -> StreamingCameraProvider {
        switch config.providerType {
        case .rtsp:
            guard let url = buildRTSPURL(for: config) else {
                throw StreamingCameraError.invalidConfiguration
            }
            return RTSPCameraProvider(id: config.id, name: config.name, url: url)
        case .tapo:
            guard let host = config.host,
                  let username = config.username,
                  let password = credentialStore.secret(for: config) else {
                throw StreamingCameraError.missingCredentials
            }
            return try TapoCameraProvider(
                id: config.id,
                name: config.name,
                host: host,
                port: config.port,
                username: username,
                password: password
            )
        case .homeAssistant:
            guard let base = config.homeAssistantBaseURL,
                  let baseURL = URL(string: base),
                  let entityId = config.cameraEntityId,
                  let token = credentialStore.secret(for: config) else {
                throw StreamingCameraError.missingCredentials
            }
            return HomeAssistantCameraProvider(
                id: config.id,
                name: config.name,
                baseURL: baseURL,
                token: token,
                entityId: entityId
            )
        }
    }

    func captureFrame(for config: StreamingCameraConfig) async throws -> UIImage {
        let provider = try provider(for: config)
        try await provider.connect()
        defer { Task { @MainActor in await provider.disconnect() } }
        return try await provider.captureFrame()
    }

    func streamURL(for config: StreamingCameraConfig) -> URL? {
        guard let provider = try? provider(for: config) else { return nil }
        return provider.streamURL()
    }

    private func buildRTSPURL(for config: StreamingCameraConfig) -> URL? {
        guard let urlString = config.rtspURLString,
              var components = URLComponents(string: urlString) else {
            return nil
        }
        if let username = config.username,
           let password = credentialStore.secret(for: config),
           !username.isEmpty {
            components.user = username
            components.password = password
        }
        return components.url
    }
}
