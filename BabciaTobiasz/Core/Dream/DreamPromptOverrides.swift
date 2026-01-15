//
//  DreamPromptOverrides.swift
//  BabciaTobiasz
//
//  Loads optional local prompt overrides from Resources/LocalDreamPrompts.json.
//

import Foundation

enum DreamPromptOverrides {
    private struct OverrideFile: Decodable {
        let personas: [String: String]?
    }

    static func prompt(for persona: BabciaPersona) -> String? {
        let key = persona.rawValue
        let value = overrides[key]?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (value?.isEmpty == false) ? value : nil
    }

    private static let overrides: [String: String] = loadOverrides()

    private static func loadOverrides() -> [String: String] {
        guard let url = overridesURL else { return [:] }
        guard let data = try? Data(contentsOf: url) else { return [:] }

        if let decoded = try? JSONDecoder().decode(OverrideFile.self, from: data),
           let personas = decoded.personas {
            return personas
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let personas = json["personas"] as? [String: String] {
            return personas
        }

        return [:]
    }

    private static var overridesURL: URL? {
        if let overrideURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("LocalDreamPrompts.json"),
           FileManager.default.fileExists(atPath: overrideURL.path) {
            return overrideURL
        }

#if SWIFT_PACKAGE
        if let moduleURL = Bundle.module.url(forResource: "LocalDreamPrompts", withExtension: "json") {
            return moduleURL
        }
#endif

        if let mainURL = Bundle.main.url(forResource: "LocalDreamPrompts", withExtension: "json") {
            return mainURL
        }

        for bundle in Bundle.allBundles + Bundle.allFrameworks {
            if let url = bundle.url(forResource: "LocalDreamPrompts", withExtension: "json") {
                return url
            }
        }

        return nil
    }
}
