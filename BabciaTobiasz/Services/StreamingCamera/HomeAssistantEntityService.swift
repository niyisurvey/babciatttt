//
//  HomeAssistantEntityService.swift
//  BabciaTobiasz
//

import Foundation

struct HomeAssistantCameraEntity: Identifiable, Hashable {
    let id: String
    let name: String
}

struct HomeAssistantEntityService {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCameraEntities(baseURL: URL, token: String) async throws -> [HomeAssistantCameraEntity] {
        let url = baseURL.appendingPathComponent("api/states")
        var request = URLRequest(url: url)
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

        let decoder = JSONDecoder()
        let states = try decoder.decode([HomeAssistantState].self, from: data)
        return states
            .filter { $0.entityId.hasPrefix("camera.") }
            .map {
                HomeAssistantCameraEntity(
                    id: $0.entityId,
                    name: $0.attributes.friendlyName ?? $0.entityId
                )
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

private struct HomeAssistantState: Decodable {
    let entityId: String
    let attributes: HomeAssistantAttributes

    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case attributes
    }
}

private struct HomeAssistantAttributes: Decodable {
    let friendlyName: String?

    enum CodingKeys: String, CodingKey {
        case friendlyName = "friendly_name"
    }
}
