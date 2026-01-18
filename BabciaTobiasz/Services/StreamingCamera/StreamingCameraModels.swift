//
//  StreamingCameraModels.swift
//  BabciaTobiasz
//

import Foundation
import SwiftData

@Model
final class StreamingCameraConfig {
    var id: UUID
    var name: String
    var providerTypeRaw: String
    var createdAt: Date
    var updatedAt: Date
    var rtspURLString: String?
    var host: String?
    var port: Int?
    var username: String?
    var homeAssistantBaseURL: String?
    var cameraEntityId: String?
    var credentialKey: String

    init(
        name: String,
        providerType: CameraProviderType,
        rtspURLString: String? = nil,
        host: String? = nil,
        port: Int? = nil,
        username: String? = nil,
        homeAssistantBaseURL: String? = nil,
        cameraEntityId: String? = nil,
        credentialKey: String? = nil
    ) {
        let cameraId = UUID()
        self.id = cameraId
        self.name = name
        self.providerTypeRaw = providerType.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.rtspURLString = rtspURLString
        self.host = host
        self.port = port
        self.username = username
        self.homeAssistantBaseURL = homeAssistantBaseURL
        self.cameraEntityId = cameraEntityId
        self.credentialKey = credentialKey ?? cameraId.uuidString
    }

    var providerType: CameraProviderType {
        get { CameraProviderType(rawValue: providerTypeRaw) ?? .rtsp }
        set { providerTypeRaw = newValue.rawValue }
    }

    func touchUpdatedAt() {
        updatedAt = Date()
    }
}
