//
//  StreamingCameraCredentialStore.swift
//  BabciaTobiasz
//

import Foundation

struct StreamingCameraCredentialStore {
    private let service = "com.babcia.tobiasz.streamingCamera"

    func secret(for config: StreamingCameraConfig) -> String? {
        KeychainService.get(service: service, account: config.credentialKey)
    }

    @discardableResult
    func setSecret(_ secret: String, for config: StreamingCameraConfig) -> Bool {
        KeychainService.set(secret, service: service, account: config.credentialKey)
    }

    @discardableResult
    func deleteSecret(for config: StreamingCameraConfig) -> Bool {
        KeychainService.delete(service: service, account: config.credentialKey)
    }
}
