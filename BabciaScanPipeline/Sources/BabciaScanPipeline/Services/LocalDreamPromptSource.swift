//
//  LocalDreamPromptSource.swift
//  BabciaScanPipeline
//
//  Added 2026-01-14 22:55 GMT
//

import Foundation

public struct LocalDreamPromptSource: DreamPromptSource {
    public init() {}

    public func prompts(for personaKey: String) -> DreamPromptBundle? {
        guard let url = resolvePromptURL() else { return nil }
        guard let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        let personas = json["personas"] as? [String: String] ?? [:]
        let personaPrompt = personas[personaKey]
        let basePrompt = stringOrLines(from: json, keys: ["basePrompt", "basePromptLines", "dreamBasePrompt", "dreamBasePromptLines"])
        let geometryPrompt = stringOrLines(from: json, keys: ["geometryPrompt", "geometryPromptLines", "dreamGeometryPrompt", "dreamGeometryPromptLines"])
        let outputPrompt = stringOrLines(from: json, keys: ["outputPrompt", "outputPromptLines", "dreamOutputPrompt", "dreamOutputPromptLines"])

        return DreamPromptBundle(
            basePrompt: basePrompt,
            personaPrompt: personaPrompt,
            geometryPrompt: geometryPrompt,
            outputPrompt: outputPrompt
        )
    }

    private func stringOrLines(from json: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = json[key] {
                if let stringValue = value as? String {
                    let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmed.isEmpty ? nil : trimmed
                }
                if let lines = value as? [String] {
                    let joined = lines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    return joined.isEmpty ? nil : joined
                }
                if let lines = value as? [Any] {
                    let strings = lines.compactMap { $0 as? String }
                    let joined = strings.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                    return joined.isEmpty ? nil : joined
                }
            }
        }
        return nil
    }

    private func resolvePromptURL() -> URL? {
        if let overrideURL = userOverrideURL,
           FileManager.default.fileExists(atPath: overrideURL.path) {
            return overrideURL
        }

        if let url = Bundle.main.url(forResource: "LocalDreamPrompts", withExtension: "json") {
            return url
        }

        for bundle in Bundle.allBundles + Bundle.allFrameworks {
            if let url = bundle.url(forResource: "LocalDreamPrompts", withExtension: "json") {
                return url
            }
        }

        return nil
    }

    private var userOverrideURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("LocalDreamPrompts.json")
    }
}
