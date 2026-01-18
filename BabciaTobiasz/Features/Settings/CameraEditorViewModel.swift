//
//  CameraEditorViewModel.swift
//  BabciaTobiasz
//

import Foundation

@MainActor
@Observable
final class CameraEditorViewModel {
    var name: String = ""
    var providerType: CameraProviderType = .rtsp
    var rtspURL: String = ""
    var host: String = ""
    var port: String = ""
    var username: String = ""
    var secret: String = ""
    var haBaseURL: String = ""
    var haEntityId: String = ""

    func populate(from camera: StreamingCameraConfig?) {
        guard let camera else { return }
        name = camera.name
        providerType = camera.providerType
        rtspURL = camera.rtspURLString ?? ""
        host = camera.host ?? ""
        if let cameraPort = camera.port {
            port = String(cameraPort)
        }
        username = camera.username ?? ""
        haBaseURL = camera.homeAssistantBaseURL ?? ""
        haEntityId = camera.cameraEntityId ?? ""
    }

    func save(manager: StreamingCameraManager, camera: StreamingCameraConfig?) throws {
        try validate(isEditing: camera != nil)

        if let camera {
            camera.name = name
            camera.providerType = providerType
            camera.rtspURLString = rtspURL.isEmpty ? nil : rtspURL
            camera.host = host.isEmpty ? nil : host
            camera.port = Int(port)
            camera.username = username.isEmpty ? nil : username
            camera.homeAssistantBaseURL = haBaseURL.isEmpty ? nil : haBaseURL
            camera.cameraEntityId = haEntityId.isEmpty ? nil : haEntityId
            manager.updateCamera(camera, secret: secret.isEmpty ? nil : secret)
        } else {
            let newCamera = StreamingCameraConfig(
                name: name,
                providerType: providerType,
                rtspURLString: rtspURL.isEmpty ? nil : rtspURL,
                host: host.isEmpty ? nil : host,
                port: Int(port),
                username: username.isEmpty ? nil : username,
                homeAssistantBaseURL: haBaseURL.isEmpty ? nil : haBaseURL,
                cameraEntityId: haEntityId.isEmpty ? nil : haEntityId
            )
            manager.addCamera(newCamera, secret: secret.isEmpty ? nil : secret)
        }
    }

    private func validate(isEditing: Bool) throws {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError(String(localized: "cameraSetup.validation.name"))
        }

        switch providerType {
        case .rtsp:
            if rtspURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError(String(localized: "cameraSetup.validation.rtspUrl"))
            }
            if URL(string: rtspURL) == nil {
                throw ValidationError(String(localized: "cameraSetup.validation.rtspUrl"))
            }
        case .tapo:
            if host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError(String(localized: "cameraSetup.validation.host"))
            }
            if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError(String(localized: "cameraSetup.validation.username"))
            }
            if secret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !isEditing {
                throw ValidationError(String(localized: "cameraSetup.validation.secret"))
            }
        case .homeAssistant:
            if haBaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError(String(localized: "cameraSetup.validation.haBaseUrl"))
            }
            if haEntityId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError(String(localized: "cameraSetup.validation.haEntityId"))
            }
            if secret.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !isEditing {
                throw ValidationError(String(localized: "cameraSetup.validation.secret"))
            }
        }
    }
}

private struct ValidationError: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}
