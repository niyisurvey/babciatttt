//
//  AppConfigService.swift
//  BabciaTobiasz
//
//  Centralized app configuration loaded from AppConfig.json.
//

import Foundation

struct AppConfig: Decodable, Sendable {
    struct GeminiPrompts: Decodable, Sendable {
        let verification: String
        let taskGeneration: String
    }

    struct Points: Decodable, Sendable {
        let microTidy: Int
        let taskCompletion: Int
        let verificationBlue: Int
        let verificationGolden: Int
    }

    struct Limits: Decodable, Sendable {
        let microTidiesPerDay: Int
    }

    struct BabciaResponses: Decodable, Sendable {
        let microTidy: [String]
    }

    let geminiPrompts: GeminiPrompts
    let points: Points
    let limits: Limits
    let babciaResponses: BabciaResponses
}

@MainActor
final class AppConfigService {
    static let shared = AppConfigService()

    private nonisolated static var defaultBundle: Bundle {
#if SWIFT_PACKAGE
        return .module
#else
        return .main
#endif
    }

    private enum StorageKeys {
        static let usedMicroTidyResponses = "appConfig.usedMicroTidyResponses"
    }

    private let bundle: Bundle
    private let userDefaults: UserDefaults
    private(set) var config: AppConfig

    init(bundle: Bundle = AppConfigService.defaultBundle, userDefaults: UserDefaults = .standard) {
        self.bundle = bundle
        self.userDefaults = userDefaults
        self.config = AppConfigService.loadFallbackConfig()
    }

    func load() {
        guard let url = resolveConfigURL() else { return }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(AppConfig.self, from: data)
            config = decoded
        } catch {
            config = AppConfigService.loadFallbackConfig()
        }
    }

    func getNextBabciaResponse() -> String {
        let responses = config.babciaResponses.microTidy
        guard !responses.isEmpty else { return "" }

        var used = Set(userDefaults.stringArray(forKey: StorageKeys.usedMicroTidyResponses) ?? [])
        var available = responses.filter { !used.contains($0) }

        if available.isEmpty {
            used = []
            available = responses
        }

        guard let next = available.randomElement() else { return "" }
        used.insert(next)
        userDefaults.set(Array(used), forKey: StorageKeys.usedMicroTidyResponses)
        return next
    }

    var microTidyLimit: Int { config.limits.microTidiesPerDay }
    var microTidyPoints: Int { config.points.microTidy }
    var taskCompletionPoints: Int { config.points.taskCompletion }
    var verificationBluePoints: Int { config.points.verificationBlue }
    var verificationGoldenPoints: Int { config.points.verificationGolden }

    private func resolveConfigURL() -> URL? {
        if let url = bundle.url(forResource: "AppConfig", withExtension: "json") {
            return url
        }
        return Bundle.main.url(forResource: "AppConfig", withExtension: "json")
    }

    private static func loadFallbackConfig() -> AppConfig {
        AppConfig(
            geminiPrompts: .init(
                verification: "",
                taskGeneration: ""
            ),
            points: .init(
                microTidy: 5,
                taskCompletion: 10,
                verificationBlue: 25,
                verificationGolden: 50
            ),
            limits: .init(microTidiesPerDay: 3),
            babciaResponses: .init(microTidy: [])
        )
    }
}
