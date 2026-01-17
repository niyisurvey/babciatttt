//
//  VerificationJudgeDependencies.swift
//  BabciaTobiasz
//
//  Dependencies for verification judging services.
//

import Foundation

protocol VerificationJudgeHTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

struct URLSessionHTTPClient: VerificationJudgeHTTPClient, @unchecked Sendable {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }
}

protocol VerificationJudgeAPIKeyProvider: Sendable {
    func loadAPIKey() -> String?
}

struct GeminiKeychainAPIKeyProvider: VerificationJudgeAPIKeyProvider {
    func loadAPIKey() -> String? {
        GeminiSecrets.apiKey()
    }
}
