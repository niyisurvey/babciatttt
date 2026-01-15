//
//  ScanPipeline.swift
//  BabciaScanPipeline
//
//  Added 2026-01-14 22:55 GMT
//

import DreamRoomEngine
import Foundation
import UIKit

public struct ScanPipeline {
    private let taskService: GeminiTaskService
    private let dreamEngine: DreamRoomEngine
    private let promptSource: DreamPromptSource

    public init(
        taskService: GeminiTaskService = GeminiTaskService(),
        dreamEngine: DreamRoomEngine = DreamRoomEngine(),
        promptSource: DreamPromptSource = LocalDreamPromptSource()
    ) {
        self.taskService = taskService
        self.dreamEngine = dreamEngine
        self.promptSource = promptSource
    }

    public func execute(
        image: UIImage,
        profile: ScanCharacterProfile,
        config: ScanPipelineConfig
    ) async -> ScanPipelineResult {
        var tasks = config.fallbackTasks
        var advice = config.fallbackAdvice
        var taskErrorMessage: String?
        var dreamErrorMessage: String?
        var dreamResult: DreamRoomResult?

        guard !config.apiKey.isEmpty else {
            let message = "API key missing."
            return ScanPipelineResult(
                tasks: tasks,
                advice: advice,
                dreamResult: nil,
                taskErrorMessage: message,
                dreamErrorMessage: message
            )
        }

        do {
            let result = try await taskService.analyzeRoom(
                image: image,
                profile: profile,
                config: config
            )
            tasks = result.tasks
            advice = result.advice
        } catch {
            taskErrorMessage = errorMessage(for: error)
        }

        let promptBundle = promptSource.prompts(for: profile.key)
        let rawPersonaPrompt = promptBundle?.personaPrompt ?? ""
        let trimmedPersonaPrompt = rawPersonaPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPersonaPrompt.isEmpty {
            dreamErrorMessage = "Dream prompt missing."
        } else if let imageData = image.jpegData(compressionQuality: 0.9) {
            let fullPrompt = promptBundle?.fullPrompt
            do {
                dreamResult = try await dreamEngine.generate(
                    beforePhotoData: imageData,
                    context: DreamRoomContext(
                        characterPrompt: trimmedPersonaPrompt,
                        fullPrompt: fullPrompt
                    ),
                    config: DreamRoomConfig(
                        apiKey: config.apiKey,
                        modelEndpoint: config.dreamModelEndpoint,
                        timeoutSeconds: config.dreamTimeout
                    )
                )
            } catch {
                dreamErrorMessage = errorMessage(for: error)
            }
        } else {
            dreamErrorMessage = "Failed to process the image."
        }

        return ScanPipelineResult(
            tasks: tasks,
            advice: advice,
            dreamResult: dreamResult,
            taskErrorMessage: taskErrorMessage,
            dreamErrorMessage: dreamErrorMessage
        )
    }

    private func errorMessage(for error: Error) -> String {
        if let urlError = error as? URLError, urlError.code == .timedOut {
            return "Request timed out."
        }
        if let localized = (error as? LocalizedError)?.errorDescription {
            let trimmed = localized.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                return trimmed
            }
        }
        let description = String(describing: error)
        return description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
