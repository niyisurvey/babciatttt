//
//  StreamingCameraProvider.swift
//  BabciaTobiasz
//

import Foundation
import UIKit

enum CameraProviderType: String, Codable, CaseIterable, Identifiable {
    case rtsp
    case tapo
    case homeAssistant

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .rtsp:
            return String(localized: "cameraProvider.rtsp")
        case .tapo:
            return String(localized: "cameraProvider.tapo")
        case .homeAssistant:
            return String(localized: "cameraProvider.homeAssistant")
        }
    }
}

protocol StreamingCameraProvider: AnyObject {
    var id: UUID { get }
    var name: String { get }
    var providerType: CameraProviderType { get }

    func connect() async throws
    func disconnect() async
    func captureFrame() async throws -> UIImage
    func streamURL() -> URL?
}

enum StreamingCameraError: LocalizedError {
    case invalidConfiguration
    case missingCredentials
    case connectionFailed
    case frameUnavailable
    case unauthorized
    case invalidResponse
    case unsupported

    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return String(localized: "streamingCamera.error.invalidConfiguration")
        case .missingCredentials:
            return String(localized: "streamingCamera.error.missingCredentials")
        case .connectionFailed:
            return String(localized: "streamingCamera.error.connectionFailed")
        case .frameUnavailable:
            return String(localized: "streamingCamera.error.frameUnavailable")
        case .unauthorized:
            return String(localized: "streamingCamera.error.unauthorized")
        case .invalidResponse:
            return String(localized: "streamingCamera.error.invalidResponse")
        case .unsupported:
            return String(localized: "streamingCamera.error.unsupported")
        }
    }
}
