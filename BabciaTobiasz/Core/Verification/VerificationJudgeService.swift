//
//  VerificationJudgeService.swift
//  BabciaTobiasz
//
//  Judges before/after photos with Gemini to verify visible cleaning progress.
//
import Foundation
/// Service that calls Gemini to judge if an after-photo is cleaner than a before-photo.
@MainActor
final class VerificationJudgeService: VerificationJudgeProtocol {
    // MARK: - Configuration
    private enum Constants {
        static let endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"
        static let imageMimeType = "image/jpeg"
    }
    private let httpClient: VerificationJudgeHTTPClient
    private let apiKeyProvider: VerificationJudgeAPIKeyProvider
    private let decoder: JSONDecoder
    // MARK: - Initialization
    init(
        httpClient: VerificationJudgeHTTPClient = URLSessionHTTPClient(),
        apiKeyProvider: VerificationJudgeAPIKeyProvider = GeminiKeychainAPIKeyProvider()
    ) {
        self.httpClient = httpClient
        self.apiKeyProvider = apiKeyProvider
        self.decoder = JSONDecoder()
    }
    // MARK: - Public Methods
    /// Judges whether the after-photo shows a cleaner room than the before-photo.
    /// - Parameters:
    ///   - beforePhoto: JPEG data of the room before cleaning.
    ///   - afterPhoto: JPEG data of the room after cleaning.
    /// - Returns: `true` if room is visibly cleaner, `false` otherwise.
    /// - Throws: `VerificationJudgeError` if judging fails.
    func judge(beforePhoto: Data, afterPhoto: Data) async throws -> Bool {
        let apiKey = try loadApiKey()
        let (beforeBase64, afterBase64) = try encodePhotos(before: beforePhoto, after: afterPhoto)
        let request = try makeRequest(apiKey: apiKey, beforeBase64: beforeBase64, afterBase64: afterBase64)
        let (data, response) = try await fetchData(for: request)
        return try parseJudgement(data: data, response: response)
    }
    // MARK: - Private Helpers
    private func loadApiKey() throws -> String {
        let rawKey = apiKeyProvider.loadAPIKey()?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !rawKey.isEmpty else { throw VerificationJudgeError.apiKeyMissing }
        return rawKey
    }

    private func encodePhotos(before: Data, after: Data) throws -> (String, String) {
        guard !before.isEmpty, !after.isEmpty else {
            throw VerificationJudgeError.invalidPhotoData
        }
        return (before.base64EncodedString(), after.base64EncodedString())
    }

    private func makeRequest(apiKey: String, beforeBase64: String, afterBase64: String) throws -> URLRequest {
        guard var components = URLComponents(string: Constants.endpoint) else {
            throw VerificationJudgeError.invalidResponse(reason: String(localized: "verification.error.reason.invalidEndpoint"))
        }
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        guard let url = components.url else {
            throw VerificationJudgeError.invalidResponse(reason: String(localized: "verification.error.reason.invalidEndpoint"))
        }

        let requestBody = GeminiRequest(contents: [
            GeminiRequestContent(role: "user", parts: [
                .text(AppConfigService.shared.config.geminiPrompts.verification),
                .image(base64: beforeBase64, mimeType: Constants.imageMimeType),
                .image(base64: afterBase64, mimeType: Constants.imageMimeType)
            ])
        ])

        let encoder = JSONEncoder()
        let bodyData: Data
        do {
            bodyData = try encoder.encode(requestBody)
        } catch {
            throw VerificationJudgeError.invalidResponse(reason: String(localized: "verification.error.reason.encodingFailed"))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        return request
    }

    private func fetchData(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        do {
            let (data, response) = try await httpClient.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw VerificationJudgeError.invalidResponse(reason: String(localized: "verification.error.reason.nonHttpResponse"))
            }
            return (data, httpResponse)
        } catch let error as VerificationJudgeError {
            throw error
        } catch {
            throw VerificationJudgeError.networkFailure(underlying: error)
        }
    }

    private func parseJudgement(data: Data, response: HTTPURLResponse) throws -> Bool {
        guard response.statusCode == 200 else {
            throw VerificationJudgeError.invalidResponse(
                reason: String(format: String(localized: "verification.error.reason.httpStatus"), response.statusCode)
            )
        }
        guard !data.isEmpty else {
            throw VerificationJudgeError.invalidResponse(reason: String(localized: "verification.error.reason.emptyResponse"))
        }
        let decoded = try decodeResponse(data: data)
        guard let text = extractResponseText(from: decoded) else {
            throw VerificationJudgeError.invalidResponse(reason: String(localized: "verification.error.reason.missingResponseText"))
        }
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized == "true" { return true }
        if normalized == "false" { return false }
        throw VerificationJudgeError.invalidResponse(
            reason: String(format: String(localized: "verification.error.reason.unexpectedResponse"), normalized)
        )
    }

    private func decodeResponse(data: Data) throws -> GeminiResponse {
        do {
            return try decoder.decode(GeminiResponse.self, from: data)
        } catch {
            throw VerificationJudgeError.invalidResponse(reason: String(localized: "verification.error.reason.decodingFailed"))
        }
    }

    private func extractResponseText(from response: GeminiResponse) -> String? {
        response.candidates?
            .first?
            .content?
            .parts?
            .compactMap { $0.text }
            .first
    }
}
