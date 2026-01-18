//
//  HomeAssistantCameraProvider.swift
//  BabciaTobiasz
//

import Foundation
import UIKit

final class HomeAssistantCameraProvider: StreamingCameraProvider {
    let id: UUID
    let name: String
    let providerType: CameraProviderType = .homeAssistant

    private let baseURL: URL
    private let token: String
    private let entityId: String
    private let session: URLSession

    init(
        id: UUID,
        name: String,
        baseURL: URL,
        token: String,
        entityId: String,
        session: URLSession = .shared
    ) {
        self.id = id
        self.name = name
        self.baseURL = baseURL
        self.token = token
        self.entityId = entityId
        self.session = session
    }

    func connect() async throws {}

    func disconnect() async {}

    func captureFrame() async throws -> UIImage {
        let snapshotURL = makeSnapshotURL()
        var request = URLRequest(url: snapshotURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw StreamingCameraError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if httpResponse.statusCode == 401 {
                throw StreamingCameraError.unauthorized
            }
            throw StreamingCameraError.connectionFailed
        }

        guard let image = UIImage(data: data) else {
            throw StreamingCameraError.frameUnavailable
        }

        return image
    }

    func streamURL() -> URL? {
        makeStreamURL()
    }

    private func makeSnapshotURL() -> URL {
        let encoded = entityId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? entityId
        return baseURL.appendingPathComponent("api/camera_proxy/\(encoded)")
    }

    private func makeStreamURL() -> URL {
        let encoded = entityId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? entityId
        return baseURL.appendingPathComponent("api/camera_proxy_stream/\(encoded)")
    }
}
