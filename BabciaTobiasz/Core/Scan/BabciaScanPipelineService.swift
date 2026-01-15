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
                advice: "Start small. You have got this.",
                dreamHeroImageData: nil,
                dreamRawImageData: nil,
                dreamFilterId: filterId,
                taskErrorMessage: "Failed to process the image.",
                dreamErrorMessage: "Failed to process the image.",
                metadata: nil
            )
        }

        let apiKey = DreamRoomSecrets.apiKey() ?? ""
        let config = ScanPipelineConfig(
            apiKey: apiKey,
            fallbackTasks: fallbackTasks,
            fallbackAdvice: persona.tagline
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
            taskErrorMessage: result.taskErrorMessage,
            dreamErrorMessage: result.dreamErrorMessage,
            metadata: result.dreamResult?.metadata
        )
    }
}
