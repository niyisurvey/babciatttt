//
//  TapoCameraProvider.swift
//  BabciaTobiasz
//

import Foundation
import UIKit

final class TapoCameraProvider: StreamingCameraProvider {
    let id: UUID
    let name: String
    let providerType: CameraProviderType = .tapo

    private let client: TapoLocalAPIClient
    private var cachedStreamURL: URL?

    init(
        id: UUID,
        name: String,
        host: String,
        port: Int?,
        username: String,
        password: String
    ) throws {
        self.id = id
        self.name = name
        self.client = try TapoLocalAPIClient(
            host: host,
            port: port,
            username: username,
            password: password
        )
    }

    func connect() async throws {
        try await client.login()
        cachedStreamURL = await client.makeStreamURL()
    }

    func disconnect() async {
        await client.reset()
        cachedStreamURL = nil
    }

    func captureFrame() async throws -> UIImage {
        if !(await client.isAuthenticated) {
            try await connect()
        }

        let data = try await client.snapshot()
        guard let image = UIImage(data: data) else {
            throw StreamingCameraError.frameUnavailable
        }
        return image
    }

    func streamURL() -> URL? {
        cachedStreamURL
    }
}

private actor TapoLocalAPIClient {
    private let baseURL: URL
    private let username: String
    private let password: String
    private let session: URLSession
    private var token: String?

    var isAuthenticated: Bool { token != nil }

    init(host: String, port: Int?, username: String, password: String, session: URLSession = .shared) throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        if let port { components.port = port }
        guard let url = components.url else {
            throw StreamingCameraError.invalidConfiguration
        }
        self.baseURL = url
        self.username = username
        self.password = password
        self.session = session
    }

    func login() async throws {
        let payload: [String: Any] = [
            "method": "login",
            "params": [
                "username": username,
                "password": password
            ]
        ]

        let response = try await request(payload: payload)
        guard let result = response["result"] as? [String: Any],
              let token = result["token"] as? String else {
            throw StreamingCameraError.invalidResponse
        }
        self.token = token
    }

    func snapshot() async throws -> Data {
        guard token != nil else {
            throw StreamingCameraError.missingCredentials
        }

        let payload: [String: Any] = [
            "method": "getSnapshot"
        ]

        let response = try await request(payload: payload)
        guard let result = response["result"] as? [String: Any],
              let dataString = result["image"] as? String,
              let data = Data(base64Encoded: dataString) else {
            throw StreamingCameraError.invalidResponse
        }
        return data
    }

    func makeStreamURL() -> URL? {
        guard let token else { return nil }
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "token", value: token)]
        return components?.url
    }

    func reset() {
        token = nil
    }

    private func request(payload: [String: Any]) async throws -> [String: Any] {
        guard let requestURL = buildRequestURL() else {
            throw StreamingCameraError.invalidConfiguration
        }
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

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

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw StreamingCameraError.invalidResponse
        }
        return json
    }

    private func buildRequestURL() -> URL? {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        if let token {
            components?.queryItems = [URLQueryItem(name: "token", value: token)]
        }
        return components?.url
    }
}
