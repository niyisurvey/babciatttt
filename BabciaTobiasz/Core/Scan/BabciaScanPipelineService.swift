//
//  BabciaScanPipelineService.swift
//  BabciaTobiasz
//
//  Added 2026-01-14 22:55 GMT
//

import BabciaScanPipeline
import DreamRoomEngine
import Foundation
import UIKit

struct BabciaScanPipelineOutput {
    let tasks: [String]
    let advice: String
    let dreamHeroImageData: Data?
    let dreamRawImageData: Data?
    let dreamFilterId: String?
    let taskErrorMessage: String?
    let dreamErrorMessage: String?
    let metadata: DreamRoomMetadata?
}

struct BabciaScanPipelineService {
    private let pipeline: ScanPipeline

    init(pipeline: ScanPipeline = ScanPipeline()) {
        self.pipeline = pipeline
    }

    func runScan(
        beforePhotoData: Data,
        persona: BabciaPersona,
        filterId: String?,
        fallbackTasks: [String]
    ) async -> BabciaScanPipelineOutput {
        guard let image = UIImage(data: beforePhotoData) else {
            return BabciaScanPipelineOutput(
                tasks: fallbackTasks,
                advice: String(localized: "areas.scan.fallback.advice"),
                dreamHeroImageData: nil,
                dreamRawImageData: nil,
                dreamFilterId: filterId,
                taskErrorMessage: String(localized: "scan.error.imageProcessingFailed"),
                dreamErrorMessage: String(localized: "scan.error.imageProcessingFailed"),
                metadata: nil
            )
        }

        let apiKey = DreamRoomSecrets.apiKey() ?? ""
        let taskPrompt = await AppConfigService.shared.config.geminiPrompts.taskGeneration
        let config = ScanPipelineConfig(
            apiKey: apiKey,
            fallbackTasks: fallbackTasks,
            fallbackAdvice: persona.localizedTagline,
            taskPromptTemplate: taskPrompt
        )

        let profile = ScanCharacterProfile(
            key: persona.rawValue,
            displayName: persona.displayName,
            tagline: persona.tagline,
            voiceGuidance: persona.voiceGuidance
        )

        let result = await pipeline.execute(
            image: image,
            profile: profile,
            config: config
        )

        let filteredHero: Data?
        if let heroData = result.dreamResult?.heroImageData {
            filteredHero = DreamFilterApplier.apply(filterId: filterId, to: heroData)
        } else {
            filteredHero = nil
        }

        return BabciaScanPipelineOutput(
            tasks: result.tasks,
            advice: result.advice,
            dreamHeroImageData: filteredHero,
            dreamRawImageData: result.dreamResult?.rawImageData,
            dreamFilterId: filterId,
            taskErrorMessage: localizedScanError(result.taskErrorMessage),
            dreamErrorMessage: localizedScanError(result.dreamErrorMessage),
            metadata: result.dreamResult?.metadata
        )
    }

    private func localizedScanError(_ message: String?) -> String? {
        guard let message else { return nil }
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        switch trimmed {
        case "API key missing.":
            return String(localized: "scan.error.apiKeyMissing")
        case "Task prompt missing.":
            return String(localized: "scan.error.missingPrompt")
        case "Dream prompt missing.":
            return String(localized: "dream.error.missingPrompt")
        case "Failed to process the image.", "Failed to process the image":
            return String(localized: "scan.error.imageProcessingFailed")
        case "Request timed out.":
            return String(localized: "scan.error.requestTimedOut")
        case "Invalid request URL":
            return String(localized: "scan.error.invalidRequest")
        case "Invalid response from API":
            return String(localized: "scan.error.invalidResponse")
        case "Failed to parse API response":
            return String(localized: "scan.error.parsingFailed")
        default:
            break
        }

        if trimmed.hasPrefix("API error ("), let range = trimmed.range(of: "): ") {
            let codeStart = trimmed.index(trimmed.startIndex, offsetBy: "API error (".count)
            let statusCode = String(trimmed[codeStart..<range.lowerBound])
            var detail = String(trimmed[range.upperBound...])
            if detail == "Unknown error" {
                detail = String(localized: "scan.error.unknown")
            }
            return String(format: String(localized: "scan.error.api"), statusCode, detail)
        }

        return trimmed
    }
}
