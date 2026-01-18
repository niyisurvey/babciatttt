//
//  GeminiTaskService.swift
//  BabciaScanPipeline
//
//  Added 2026-01-14 22:55 GMT
//

import Foundation
import UIKit

public struct GeminiTaskService: Sendable {
    public init() {}

    func analyzeRoom(
        image: UIImage,
        profile: ScanCharacterProfile,
        config: ScanPipelineConfig
    ) async throws -> (tasks: [String], advice: String) {
        guard let resizedImage = image.resizedTo(maxDimension: 1024),
              let imageData = resizedImage.jpegData(compressionQuality: 0.8) else {
            throw GeminiTaskServiceError.imageProcessingFailed
        }

        let base64Image = imageData.base64EncodedString()

        let promptTemplate = config.taskPromptTemplate?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let promptTemplate, !promptTemplate.isEmpty else {
            throw GeminiTaskServiceError.missingPrompt
        }
        let prompt = renderPrompt(template: promptTemplate, profile: profile)

        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt],
                        [
                            "inline_data": [
                                "mime_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json"
            ]
        ]

        guard let url = URL(string: "\(config.taskModelEndpoint.absoluteString)?key=\(config.apiKey)") else {
            throw GeminiTaskServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        request.timeoutInterval = config.taskTimeout

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiTaskServiceError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiTaskServiceError.apiError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        return try parseAnalysisResponse(data, config: config)
    }

    private func parseAnalysisResponse(
        _ data: Data,
        config: ScanPipelineConfig
    ) throws -> (tasks: [String], advice: String) {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiTaskServiceError.parsingFailed
        }

        let cleanedText = sanitizeResponseText(text)
        return parseTasksAndAdvice(
            from: cleanedText,
            fallbackTasks: config.fallbackTasks,
            fallbackAdvice: config.fallbackAdvice
        )
    }

    private func sanitizeResponseText(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseTasksAndAdvice(
        from text: String,
        fallbackTasks: [String],
        fallbackAdvice: String
    ) -> (tasks: [String], advice: String) {
        if let jsonResult = parseJSONTasksAndAdvice(from: text) {
            return jsonResult
        }

        let lines = text.split(separator: "\n").map { String($0) }
        var tasks: [String] = []
        var adviceLines: [String] = []

        for line in lines {
            if let task = parseBulletTask(from: line) {
                tasks.append(task)
            } else {
                adviceLines.append(line)
            }
        }

        if tasks.isEmpty {
            tasks = fallbackTasks
        }

        let advice = adviceLines.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        return (tasks: tasks, advice: advice.isEmpty ? fallbackAdvice : advice)
    }

    private func parseJSONTasksAndAdvice(from text: String) -> (tasks: [String], advice: String)? {
        if let parsed = parseJSONTasksAndAdvice(from: text.data(using: .utf8)) {
            return parsed
        }

        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else {
            return nil
        }

        let jsonSlice = String(text[start...end])
        return parseJSONTasksAndAdvice(from: jsonSlice.data(using: .utf8))
    }

    private func parseJSONTasksAndAdvice(from data: Data?) -> (tasks: [String], advice: String)? {
        guard let data,
              let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let tasks = response["tasks"] as? [String],
              let advice = response["advice"] as? String else {
            return nil
        }

        return (tasks: tasks, advice: advice)
    }

    private func parseBulletTask(from line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        let bulletPrefixes = ["- ", "• ", "* "]
        for prefix in bulletPrefixes {
            if trimmed.hasPrefix(prefix) {
                return String(trimmed.dropFirst(prefix.count))
            }
        }
        return nil
    }

    private func renderPrompt(template: String, profile: ScanCharacterProfile) -> String {
        template
            .replacingOccurrences(of: "{{displayName}}", with: profile.displayName)
            .replacingOccurrences(of: "{{tagline}}", with: profile.tagline)
            .replacingOccurrences(of: "{{voiceGuidance}}", with: profile.voiceGuidance)
    }
}

enum GeminiTaskServiceError: Error, LocalizedError {
    case imageProcessingFailed
    case missingPrompt
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case parsingFailed

    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Failed to process the image"
        case .missingPrompt:
            return "Task prompt missing."
        case .invalidURL:
            return "Invalid request URL"
        case .invalidResponse:
            return "Invalid response from API"
        case .apiError(let statusCode, let message):
            return "API error (\(statusCode)): \(message)"
        case .parsingFailed:
            return "Failed to parse API response"
        }
    }
}
