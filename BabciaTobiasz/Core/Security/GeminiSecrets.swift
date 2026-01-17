//
//  GeminiSecrets.swift
//  BabciaTobiasz
//
//  Loads the Gemini API key from Keychain or Secrets.plist.
//

import Foundation

enum GeminiSecrets {
    static func apiKey() -> String? {
        if let stored = GeminiKeychain.load(), !stored.isEmpty {
            return stored
        }
        let secretsURL: URL?
#if SWIFT_PACKAGE
        secretsURL = Bundle.module.url(forResource: "Secrets", withExtension: "plist")
#else
        secretsURL = Bundle.main.url(forResource: "Secrets", withExtension: "plist")
#endif
        guard let url = secretsURL else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                return nil
            }
            let rawKey = (plist["GEMINI_API_KEY"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return rawKey.isEmpty ? nil : rawKey
        } catch {
            return nil
        }
    }
}
