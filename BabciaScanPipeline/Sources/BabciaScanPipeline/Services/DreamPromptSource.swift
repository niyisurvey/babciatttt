//
//  DreamPromptSource.swift
//  BabciaScanPipeline
//
//  Added 2026-01-14 22:55 GMT
//

import Foundation

public struct DreamPromptBundle: Sendable {
    public let basePrompt: String?
    public let personaPrompt: String?
    public let geometryPrompt: String?
    public let outputPrompt: String?

    public init(
        basePrompt: String?,
        personaPrompt: String?,
        geometryPrompt: String?,
        outputPrompt: String?
    ) {
        self.basePrompt = basePrompt
        self.personaPrompt = personaPrompt
        self.geometryPrompt = geometryPrompt
        self.outputPrompt = outputPrompt
    }

    public var fullPrompt: String? {
        guard let basePrompt = trimmed(basePrompt),
              let personaPrompt = trimmed(personaPrompt),
              let geometryPrompt = trimmed(geometryPrompt),
              let outputPrompt = trimmed(outputPrompt) else {
            return nil
        }

        let sections = [basePrompt, personaPrompt, geometryPrompt, outputPrompt]
        return sections.joined(separator: "\n\n")
    }

    private func trimmed(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

public protocol DreamPromptSource: Sendable {
    func prompts(for personaKey: String) -> DreamPromptBundle?
}
