//
//  DreamPipelineService.swift
//  BabciaTobiasz
//
//  Orchestrates DreamRoomEngine output + optional filter application.
//

import DreamRoomEngine
import Foundation
import UIKit

struct DreamPipelineResult {
    let heroImageData: Data
    let rawImageData: Data
    let filterId: String?
    let metadata: DreamRoomMetadata
}

enum DreamPipelineError: LocalizedError {
    case missingAPIKey
    case missingPrompt
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return String(localized: "dream.error.apiKeyMissing")
        case .missingPrompt:
            return String(localized: "dream.error.missingPrompt")
        case .invalidImageData:
            return String(localized: "dream.error.invalidImage")
        }
    }
}

struct DreamPipelineService {
    private let engine: DreamRoomEngine
    private let apiKeyProvider: @Sendable () -> String?

    init(
        engine: DreamRoomEngine = DreamRoomEngine(),
        apiKeyProvider: @Sendable @escaping () -> String? = { DreamRoomSecrets.apiKey() }
    ) {
        self.engine = engine
        self.apiKeyProvider = apiKeyProvider
    }

    func generateDream(
        beforePhotoData: Data,
        characterPrompt: String,
        filterId: String?
    ) async throws -> DreamPipelineResult {
        guard let apiKey = apiKeyProvider(), !apiKey.isEmpty else {
            throw DreamPipelineError.missingAPIKey
        }

        let trimmedPrompt = characterPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else {
            throw DreamPipelineError.missingPrompt
        }

        let result = try await engine.generate(
            beforePhotoData: beforePhotoData,
            context: DreamRoomContext(characterPrompt: trimmedPrompt),
            config: DreamRoomConfig(apiKey: apiKey)
        )

        let filteredHero = DreamFilterApplier.apply(
            filterId: filterId,
            to: result.heroImageData
        )

        return DreamPipelineResult(
            heroImageData: filteredHero,
            rawImageData: result.rawImageData,
            filterId: filterId,
            metadata: result.metadata
        )
    }
}
