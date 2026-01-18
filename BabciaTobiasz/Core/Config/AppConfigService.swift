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

    struct Pierogi: Decodable, Sendable {
        let goldenChancePercent: Int
    }

    struct SpotCheck: Decodable, Sendable {
        struct Points: Decodable, Sendable {
            let spotless: Int
            let tidy: Int
            let messy: Int
        }

        let minAreasRequired: Int
        let checksPerDay: Int
        let tidyThreshold: Int
        let sameAreaCooldownHours: Int
        let points: Points
    }

    struct BabciaResponses: Decodable, Sendable {
        let microTidy: [String]
        let spotCheck: [String]
    }

    let geminiPrompts: GeminiPrompts
    let points: Points
    let limits: Limits
    let pierogi: Pierogi
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

    var microTidyLimit: Int { config.limits.microTidiesPerDay }
    var microTidyPoints: Int { config.points.microTidy }
    var taskCompletionPoints: Int { config.points.taskCompletion }
    var verificationBluePoints: Int { config.points.verificationBlue }
    var verificationGoldenPoints: Int { config.points.verificationGolden }
    var pierogiGoldenChancePercent: Int { config.pierogi.goldenChancePercent }
    var spotCheckMinAreasRequired: Int { config.spotCheck.minAreasRequired }
    var spotCheckLimit: Int { config.spotCheck.checksPerDay }
    var spotCheckTidyThreshold: Int { config.spotCheck.tidyThreshold }
    var spotCheckCooldownHours: Int { config.spotCheck.sameAreaCooldownHours }
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
            points: .init(
                microTidy: 5,
                taskCompletion: 10,
                verificationBlue: 25,
                verificationGolden: 50
            ),
            limits: .init(microTidiesPerDay: 3),
            pierogi: .init(goldenChancePercent: 10),
            spotCheck: .init(
                minAreasRequired: 3,
                checksPerDay: 3,
                tidyThreshold: 2,
                sameAreaCooldownHours: 24,
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
