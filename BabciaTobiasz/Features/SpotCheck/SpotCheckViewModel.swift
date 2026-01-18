//
//  SpotCheckViewModel.swift
//  BabciaTobiasz
//

import Foundation
import SwiftData

@MainActor
@Observable
final class SpotCheckViewModel {
    enum Result: Equatable {
        case spotless
        case tidy
        case messy
    }

    var areas: [Area] = []
    var selectedArea: Area?
    var dailyCount: Int = 0
    var isLoading: Bool = false
    var isProcessing: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var errorAction: FriendlyErrorAction?
    var lastResult: Result?
    var lastTaskCount: Int?
    var lastAreaName: String?
    var lastResponse: String?

    private var persistenceService: PersistenceService?
    private var potService: PotService?
    private var scanPipelineService: BabciaScanPipelineService?
    private var currentUser: User?
    private let configService: AppConfigService
    @ObservationIgnored private let userDefaults: UserDefaults
    @ObservationIgnored private let calendar: Calendar
    private var areaCooldowns: [String: TimeInterval] = [:]

    private enum StorageKeys {
        static let spotCheckCount = "spotCheck.dailyCount"
        static let spotCheckDate = "spotCheck.dayStart"
        static let spotCheckAreaCooldowns = "spotCheck.areaCooldowns"
    }

    init(
        configService: AppConfigService? = nil,
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.configService = configService ?? .shared
        self.userDefaults = userDefaults
        self.calendar = calendar
        self.areaCooldowns = Self.loadAreaCooldowns(userDefaults: userDefaults)
        refreshDailyState()
    }

    func configure(modelContext: ModelContext, scanPipelineService: BabciaScanPipelineService) {
        let persistence = PersistenceService(modelContext: modelContext)
        persistenceService = persistence
        potService = PotService(modelContext: modelContext)
        self.scanPipelineService = scanPipelineService
        do {
            currentUser = try persistence.fetchOrCreateUser()
        } catch {
            handleError(error)
        }
    }

    func refresh() {
        refreshDailyState()
        loadAreas()
    }

    func loadAreas() {
        guard let persistenceService else { return }
        do {
            isLoading = true
            defer { isLoading = false }
            areas = try persistenceService.fetchAreas()
            if let selectedArea, (!areas.contains(where: { $0.id == selectedArea.id }) || !isAreaEligible(selectedArea)) {
                self.selectedArea = nil
            }
        } catch {
            handleError(error)
        }
    }

    func pickRandomArea() {
        let eligible = eligibleAreas()
        selectedArea = eligible.randomElement()
    }

    func canDoSpotCheck() -> Bool {
        refreshDailyState()
        guard meetsMinimumAreas else { return false }
        return dailyCount < spotCheckLimit && !eligibleAreas().isEmpty
    }

    func canRevealArea() -> Bool {
        refreshDailyState()
        return meetsMinimumAreas && dailyCount < spotCheckLimit && !eligibleAreas().isEmpty
    }

    func clearSelection() {
        selectedArea = nil
    }

    func performSpotCheck(imageData: Data) async {
        guard canDoSpotCheck() else { return }
        guard let area = selectedArea else { return }
        guard isAreaEligible(area) else { return }
        guard let scanPipelineService else {
            errorMessage = String(localized: "spotCheck.error.pipelineUnavailable")
            showError = true
            return
        }

        do {
            isProcessing = true
            defer { isProcessing = false }

            let fallbackTasks = fallbackTaskTemplates()
            let scanResult = await scanPipelineService.runScan(
                beforePhotoData: imageData,
                persona: area.persona,
                filterId: nil,
                fallbackTasks: fallbackTasks
            )

            let taskCount = max(0, scanResult.tasks.count)
            let result = evaluateResult(taskCount: taskCount)
            let points = points(for: result)

            if let potService, let currentUser, points > 0 {
                try potService.addPoints(points, to: currentUser)
            }

            lastResult = result
            lastTaskCount = taskCount
            lastAreaName = area.name
            lastResponse = configService.getNextSpotCheckResponse()

            dailyCount += 1
            persistDailyState()
            updateCooldown(for: area.id)
            clearSelection()
        } catch {
            handleError(error)
        }
    }

    var meetsMinimumAreas: Bool {
        areas.count >= spotCheckMinAreasRequired
    }

    var spotCheckLimit: Int { configService.spotCheckLimit }
    var spotCheckMinAreasRequired: Int { configService.spotCheckMinAreasRequired }
    var spotCheckTidyThreshold: Int { configService.spotCheckTidyThreshold }
    var spotCheckCooldownHours: Int { configService.spotCheckCooldownHours }
    var spotCheckPoints: AppConfig.SpotCheck.Points { configService.spotCheckPoints }
    var eligibleAreaCount: Int { eligibleAreas().count }
    var totalAreaCount: Int { areas.count }

    var cooldownRemaining: TimeInterval? {
        let now = Date().timeIntervalSince1970
        let cooldownSeconds = TimeInterval(spotCheckCooldownHours) * 3600
        let remaining = areaCooldowns.values
            .map { max(0, cooldownSeconds - (now - $0)) }
            .filter { $0 > 0 }
        return remaining.min()
    }

    var cooldownRemainingText: String? {
        guard let remaining = cooldownRemaining else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = remaining >= 3600 ? [.hour, .minute] : [.minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: remaining)
    }

    private func eligibleAreas() -> [Area] {
        areas.filter { isAreaEligible($0) }
    }

    private func isAreaEligible(_ area: Area) -> Bool {
        let now = Date()
        let cooldownSeconds = TimeInterval(spotCheckCooldownHours) * 3600
        guard let lastCheck = areaCooldowns[area.id.uuidString] else { return true }
        return now.timeIntervalSince1970 - lastCheck >= cooldownSeconds
    }

    private func evaluateResult(taskCount: Int) -> Result {
        if taskCount == 0 {
            return .spotless
        }
        if taskCount <= spotCheckTidyThreshold {
            return .tidy
        }
        return .messy
    }

    private func points(for result: Result) -> Int {
        switch result {
        case .spotless:
            return spotCheckPoints.spotless
        case .tidy:
            return spotCheckPoints.tidy
        case .messy:
            return spotCheckPoints.messy
        }
    }

    private func updateCooldown(for areaId: UUID) {
        areaCooldowns[areaId.uuidString] = Date().timeIntervalSince1970
        persistAreaCooldowns()
    }

    private func refreshDailyState() {
        let today = calendar.startOfDay(for: Date())
        let storedTimestamp = userDefaults.double(forKey: StorageKeys.spotCheckDate)
        if storedTimestamp == 0 {
            dailyCount = 0
            userDefaults.set(today.timeIntervalSince1970, forKey: StorageKeys.spotCheckDate)
            userDefaults.set(0, forKey: StorageKeys.spotCheckCount)
            return
        }

        let storedDate = Date(timeIntervalSince1970: storedTimestamp)
        if calendar.isDate(storedDate, inSameDayAs: today) {
            dailyCount = userDefaults.integer(forKey: StorageKeys.spotCheckCount)
        } else {
            dailyCount = 0
            userDefaults.set(today.timeIntervalSince1970, forKey: StorageKeys.spotCheckDate)
            userDefaults.set(0, forKey: StorageKeys.spotCheckCount)
        }
    }

    private func persistDailyState() {
        let today = calendar.startOfDay(for: Date())
        userDefaults.set(today.timeIntervalSince1970, forKey: StorageKeys.spotCheckDate)
        userDefaults.set(dailyCount, forKey: StorageKeys.spotCheckCount)
    }

    private func persistAreaCooldowns() {
        userDefaults.set(areaCooldowns, forKey: StorageKeys.spotCheckAreaCooldowns)
    }

    private static func loadAreaCooldowns(userDefaults: UserDefaults) -> [String: TimeInterval] {
        let stored = userDefaults.dictionary(forKey: StorageKeys.spotCheckAreaCooldowns) ?? [:]
        var result: [String: TimeInterval] = [:]
        for (key, value) in stored {
            if let number = value as? NSNumber {
                result[key] = number.doubleValue
            } else if let doubleValue = value as? Double {
                result[key] = doubleValue
            }
        }
        return result
    }

    private func fallbackTaskTemplates() -> [String] {
        [
            String(localized: "areas.scan.fallback.task.clearSurface"),
            String(localized: "areas.scan.fallback.task.putAway"),
            String(localized: "areas.scan.fallback.task.wipeSurface"),
            String(localized: "areas.scan.fallback.task.collectTrash"),
            String(localized: "areas.scan.fallback.task.resetArea")
        ]
    }

    private func handleError(_ error: Error) {
        let friendly = FriendlyErrorMapper.map(error)
        errorMessage = friendly.message
        errorAction = friendly.action
        showError = true
    }
}
