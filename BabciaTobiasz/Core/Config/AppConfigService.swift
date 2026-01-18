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
        let taskCompletion: Int
    }

    struct MicroTidy: Decodable, Sendable {
        let dailyLimit: Int
        let points: Int
    }

    struct Verification: Decodable, Sendable {
        let bluePoints: Int
        let goldenPoints: Int
        let goldenChance: Int
    }

    struct Kitchen: Decodable, Sendable {
        let defaultTarget: Int
        let maxTarget: Int
    }

    struct Tutorial: Decodable, Sendable {
        let showWalkthrough: Bool
        let showCameraSetup: Bool
        let showThemeSelection: Bool
    }

    struct SpotCheck: Decodable, Sendable {
        struct Points: Decodable, Sendable {
            let spotless: Int
            let tidy: Int
            let messy: Int
        }

        let minAreas: Int
        let dailyLimit: Int
        let tidyThreshold: Int
        let cooldownHours: Int
        let points: Points

        private enum CodingKeys: String, CodingKey {
            case minAreas
            case dailyLimit
            case tidyThreshold
            case cooldownHours = "cooldown"
            case points
        }
    }

    struct BabciaResponses: Decodable, Sendable {
        let microTidy: [String]
        let spotCheck: [String]
    }

    let geminiPrompts: GeminiPrompts
    let points: Points
    let microTidy: MicroTidy
    let verification: Verification
    let kitchen: Kitchen
    let tutorial: Tutorial
    let spotCheck: SpotCheck
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
        static let usedSpotCheckResponses = "appConfig.usedSpotCheckResponses"
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

    func getNextSpotCheckResponse() -> String {
        let responses = config.babciaResponses.spotCheck
        guard !responses.isEmpty else { return "" }

        var used = Set(userDefaults.stringArray(forKey: StorageKeys.usedSpotCheckResponses) ?? [])
        var available = responses.filter { !used.contains($0) }

        if available.isEmpty {
            used = []
            available = responses
        }

        guard let next = available.randomElement() else { return "" }
        used.insert(next)
        userDefaults.set(Array(used), forKey: StorageKeys.usedSpotCheckResponses)
        return next
    }

    var microTidyLimit: Int { config.microTidy.dailyLimit }
    var microTidyPoints: Int { config.microTidy.points }
    var taskCompletionPoints: Int { config.points.taskCompletion }
    var verificationBluePoints: Int { config.verification.bluePoints }
    var verificationGoldenPoints: Int { config.verification.goldenPoints }
    var verificationGoldenChancePercent: Int { config.verification.goldenChance }
    var kitchenDefaultTarget: Int { config.kitchen.defaultTarget }
    var kitchenMaxTarget: Int { config.kitchen.maxTarget }
    var tutorialShowWalkthrough: Bool { config.tutorial.showWalkthrough }
    var tutorialShowCameraSetup: Bool { config.tutorial.showCameraSetup }
    var tutorialShowThemeSelection: Bool { config.tutorial.showThemeSelection }
    var spotCheckMinAreasRequired: Int { config.spotCheck.minAreas }
    var spotCheckLimit: Int { config.spotCheck.dailyLimit }
    var spotCheckTidyThreshold: Int { config.spotCheck.tidyThreshold }
    var spotCheckCooldownHours: Int { config.spotCheck.cooldownHours }
    var spotCheckPoints: AppConfig.SpotCheck.Points { config.spotCheck.points }

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
            points: .init(taskCompletion: 10),
            microTidy: .init(dailyLimit: 3, points: 5),
            verification: .init(bluePoints: 25, goldenPoints: 50, goldenChance: 10),
            kitchen: .init(defaultTarget: 1, maxTarget: 10),
            tutorial: .init(showWalkthrough: true, showCameraSetup: true, showThemeSelection: true),
            spotCheck: .init(
                minAreas: 3,
                dailyLimit: 3,
                tidyThreshold: 2,
                cooldownHours: 24,
                points: .init(
                    spotless: 15,
                    tidy: 8,
                    messy: 0
                )
            ),
            babciaResponses: .init(microTidy: [], spotCheck: [])
        )
    }
}
