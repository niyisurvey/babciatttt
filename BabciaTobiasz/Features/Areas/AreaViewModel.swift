// AreaViewModel.swift
// BabciaTobiasz

import Foundation
import SwiftUI
import SwiftData

@MainActor
@Observable
final class AreaViewModel {
    
    // MARK: - State
    
    var areas: [Area] = []
    var selectedArea: Area?
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var showAreaForm: Bool = false
    var editingArea: Area?
    var searchText: String = ""
    var filterOption: FilterOption = .all
    // Added 2026-01-14 20:55 GMT
    var isGeneratingDream: Bool = false
    // Added 2026-01-14 20:55 GMT
    var dreamStatusMessage: String?
    var dailyBowlTarget: Int = 1 {
        didSet {
            if dailyBowlTarget < 1 {
                dailyBowlTarget = 1
                return
            }
            userDefaults.set(dailyBowlTarget, forKey: StorageKeys.dailyBowlTarget)
        }
    }
    var streakCount: Int = 0 {
        didSet {
            userDefaults.set(streakCount, forKey: StorageKeys.streakCount)
        }
    }
    private var lastPhotoDayTimestamp: Double = 0 {
        didSet {
            userDefaults.set(lastPhotoDayTimestamp, forKey: StorageKeys.lastPhotoDayTimestamp)
        }
    }
    
    // MARK: - Filter Options
    
    enum FilterOption: String, CaseIterable, Identifiable {
        case all = "All"
        case completed = "Completed Today"
        case incomplete = "Not Completed"
        
        var id: String { rawValue }
    }
    
    // MARK: - Dependencies
    
    private var persistenceService: PersistenceService?
    private var notificationService: NotificationService?
    // Added 2026-01-14 22:55 GMT
    private var scanPipelineService: BabciaScanPipelineService?
    @ObservationIgnored private let userDefaults = UserDefaults.standard

    private enum StorageKeys {
        static let dailyBowlTarget = "dailyBowlTarget"
        static let streakCount = "streakCount"
        static let lastPhotoDayTimestamp = "lastPhotoDayTimestamp"
        static let spentPoints = "spentPoints"
        static let unlockedFilters = "unlockedFilters"
        static let activeFilterId = "activeFilterId"
    }
    
    // MARK: - Computed Properties
    
    var filteredAreas: [Area] {
        var result = areas
        
        if !searchText.isEmpty {
            result = result.filter { area in
                area.name.localizedCaseInsensitiveContains(searchText) ||
                (area.areaDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        switch filterOption {
        case .all:
            break
        case .completed:
            result = result.filter { isAreaCompletedToday($0) }
        case .incomplete:
            result = result.filter { !isAreaCompletedToday($0) }
        }
        
        return result
    }
    
    var completedTodayCount: Int {
        bowlsCompletedToday.count
    }
    var totalAreasCount: Int { areas.count }
    var bowlsStartedTodayCount: Int { bowlsStartedToday.count }
    var bowlsCompletedTodayCount: Int { bowlsCompletedToday.count }
    var isKitchenClosed: Bool { !canStartBowlToday }
    
    var todayCompletionPercentage: Double {
        guard dailyBowlTarget > 0 else { return 0 }
        return min(1, Double(completedTodayCount) / Double(dailyBowlTarget))
    }
    
    var bestStreak: Int { streakCount }
    var totalCompletions: Int {
        areas.reduce(0) { total, area in
            let taskCount = area.bowls?.flatMap { $0.tasks ?? [] }.filter { $0.isCompleted }.count ?? 0
            return total + taskCount
        }
    }

    var totalPotPoints: Int {
        let total = areas
            .compactMap { $0.bowls }
            .flatMap { $0 }
            .reduce(0.0) { $0 + $1.totalPoints }
        return max(0, Int(total.rounded()))
    }

    var availablePotPoints: Int {
        max(0, totalPotPoints - spentPoints)
    }

    var hasVerifiedToday: Bool {
        !bowlsVerifiedToday.isEmpty
    }

    var hasCompletedUnverifiedToday: Bool {
        bowlsCompletedToday.contains { $0.verificationOutcome != .passed }
    }
    
    // MARK: - Initialization
    
    init(
        persistenceService: PersistenceService? = nil,
        notificationService: NotificationService? = nil,
        scanPipelineService: BabciaScanPipelineService? = nil
    ) {
        self.persistenceService = persistenceService
        self.notificationService = notificationService
        self.scanPipelineService = scanPipelineService
        loadPersistentState()
    }
    
    // MARK: - Configuration
    
    func configure(
        persistenceService: PersistenceService,
        notificationService: NotificationService,
        // Added 2026-01-14 22:55 GMT
        scanPipelineService: BabciaScanPipelineService
    ) {
        self.persistenceService = persistenceService
        self.notificationService = notificationService
        self.scanPipelineService = scanPipelineService
    }

    private func loadPersistentState() {
        if let storedTarget = userDefaults.object(forKey: StorageKeys.dailyBowlTarget) as? NSNumber {
            dailyBowlTarget = max(1, storedTarget.intValue)
        } else {
            dailyBowlTarget = 1
        }

        if let storedStreak = userDefaults.object(forKey: StorageKeys.streakCount) as? NSNumber {
            streakCount = max(0, storedStreak.intValue)
        } else {
            streakCount = 0
        }

        if let storedTimestamp = userDefaults.object(forKey: StorageKeys.lastPhotoDayTimestamp) as? NSNumber {
            lastPhotoDayTimestamp = storedTimestamp.doubleValue
        } else {
            lastPhotoDayTimestamp = 0
        }
    }

    private var spentPoints: Int {
        get { userDefaults.object(forKey: StorageKeys.spentPoints) as? Int ?? 0 }
        set { userDefaults.set(max(0, newValue), forKey: StorageKeys.spentPoints) }
    }

    private var unlockedFilterIds: Set<String> {
        get { Set(userDefaults.stringArray(forKey: StorageKeys.unlockedFilters) ?? []) }
        set { userDefaults.set(Array(newValue), forKey: StorageKeys.unlockedFilters) }
    }

    var activeFilterId: String? {
        get { userDefaults.string(forKey: StorageKeys.activeFilterId) }
        set { userDefaults.set(newValue, forKey: StorageKeys.activeFilterId) }
    }
    
    // MARK: - Data Loading
    
    func loadAreas() {
        guard let persistenceService = persistenceService else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            areas = try persistenceService.fetchAreas()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - CRUD Operations
    
    func createArea(
        name: String,
        description: String?,
        iconName: String,
        colorHex: String,
        dreamImageName: String? = nil,
        persona: BabciaPersona = .classic
    ) async {
        guard let persistenceService = persistenceService else { return }
        
        let area = Area(
            name: name,
            description: description,
            iconName: iconName,
            colorHex: colorHex,
            dreamImageName: dreamImageName,
            persona: persona
        )
        
        do {
            try persistenceService.createArea(area)
            areas.insert(area, at: 0)
        } catch {
            handleError(error)
        }
    }
    
    func updateArea(_ area: Area) async {
        guard let persistenceService = persistenceService else { return }
        
        do {
            try persistenceService.updateArea(area)
        } catch {
            handleError(error)
        }
    }
    
    func deleteArea(_ area: Area) {
        guard let persistenceService = persistenceService else { return }
        
        do {
            try persistenceService.deleteArea(area)
            areas.removeAll { $0.id == area.id }
        } catch {
            handleError(error)
        }
    }
    
    func deleteAreas(at offsets: IndexSet) {
        for index in offsets {
            deleteArea(filteredAreas[index])
        }
    }
    
    // MARK: - Bowl + Task Operations
    
    func startBowl(for area: Area, verificationRequested: Bool, beforePhotoData: Data?) async {
        guard let persistenceService = persistenceService else { return }

        guard canStartBowlToday else {
            errorMessage = "Kitchen Closed. Daily target reached."
            showError = true
            return
        }

        // Added 2026-01-14 21:13 GMT
        guard area.inProgressBowl == nil else {
            errorMessage = "Finish the current session before starting a new scan."
            showError = true
            return
        }
        // Added 2026-01-14 21:13 GMT
        guard let beforePhotoData else {
            errorMessage = "Scan photo required to start a session."
            showError = true
            return
        }

        do {
            isLoading = true
            // Added 2026-01-14 22:55 GMT
            isGeneratingDream = true
            dreamStatusMessage = "Scanning..."
            defer {
                isLoading = false
                isGeneratingDream = false
            }

            let fallbackTasks = Array(genericTaskTemplates().prefix(5))
            let scanResult = await scanPipelineService?.runScan(
                beforePhotoData: beforePhotoData,
                persona: area.persona,
                filterId: activeFilterId,
                fallbackTasks: fallbackTasks
            ) ?? BabciaScanPipelineOutput(
                tasks: fallbackTasks,
                advice: "Start small. You have got this.",
                dreamHeroImageData: nil,
                dreamRawImageData: nil,
                dreamFilterId: activeFilterId,
                taskErrorMessage: "Scan pipeline unavailable.",
                dreamErrorMessage: "Scan pipeline unavailable.",
                metadata: nil
            )

            let tasks = scanResult.tasks.prefix(5).map { CleaningTask(title: $0) }
            let bowl = try persistenceService.createBowl(
                for: area,
                tasks: Array(tasks),
                verificationRequested: verificationRequested,
                beforePhotoData: beforePhotoData
            )
            if verificationRequested {
                bowl.verificationRequestedAt = Date()
            }
            updateStreakForNewBowl()

            if let heroData = scanResult.dreamHeroImageData {
                bowl.dreamHeroImageData = heroData
                bowl.dreamRawImageData = scanResult.dreamRawImageData
                bowl.dreamFilterId = scanResult.dreamFilterId
                bowl.dreamGeneratedAt = Date()
                area.dreamImageName = nil
                dreamStatusMessage = "Dream updated."
            } else {
                area.dreamImageName = fallbackDreamAssetName(for: area.persona)
                dreamStatusMessage = "Dream failed; using Babcia reference art."
            }

            try persistenceService.save()

            if let taskError = scanResult.taskErrorMessage, !taskError.isEmpty {
                errorMessage = taskError
                showError = true
            } else if let dreamError = scanResult.dreamErrorMessage, !dreamError.isEmpty {
                errorMessage = dreamError
                showError = true
            }
        } catch {
            handleError(error)
        }
    }
    
    func toggleTaskCompletion(_ task: CleaningTask) {
        guard let persistenceService = persistenceService else { return }
        do {
            guard let bowl = task.bowl else { return }
            if task.isCompleted {
                task.completedAt = nil
                bowl.basePoints = max(0, bowl.basePoints - task.points)
            } else {
                task.completedAt = Date()
                bowl.basePoints += task.points
            }
            updateBowlCompletionState(bowl)
            updateBowlTotals(bowl)
            try persistenceService.save()
        } catch {
            handleError(error)
        }
    }
    
    func finalizeVerification(for bowl: AreaBowl, tier: BowlVerificationTier, outcome: BowlVerificationOutcome, afterPhotoData: Data?) {
        guard let persistenceService = persistenceService else { return }
        do {
            bowl.verificationTier = tier
            bowl.verificationOutcome = outcome
            bowl.verifiedAt = Date()
            if let afterPhotoData {
                bowl.afterPhotoData = afterPhotoData
            }
            updateBowlTotals(bowl)
            try persistenceService.save()
        } catch {
            handleError(error)
        }
    }
    
    // MARK: - Form Management
    
    func addNewArea() {
        editingArea = nil
        showAreaForm = true
    }
    
    func editArea(_ area: Area) {
        editingArea = area
        showAreaForm = true
    }
    
    func closeForm() {
        showAreaForm = false
        editingArea = nil
    }
    
    // MARK: - Error Handling
    
    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
    
    func dismissError() {
        showError = false
        errorMessage = nil
    }

    // MARK: - Filters / Economy

    func isFilterUnlocked(_ id: String) -> Bool {
        unlockedFilterIds.contains(id)
    }

    func unlockFilter(_ id: String, cost: Int) {
        guard availablePotPoints >= cost else {
            errorMessage = "Not enough points."
            showError = true
            return
        }
        spentPoints += cost
        unlockedFilterIds.insert(id)
    }

    func applyFilter(_ id: String) {
        activeFilterId = id
    }
}

// MARK: - Statistics

extension AreaViewModel {
    struct AreaStatistics {
        let totalAreas: Int
        let completedToday: Int
        let bestStreak: Int
        let totalCompletions: Int
        let completionRate: Double
    }
    
    var statistics: AreaStatistics {
        AreaStatistics(
            totalAreas: totalAreasCount,
            completedToday: completedTodayCount,
            bestStreak: bestStreak,
            totalCompletions: totalCompletions,
            completionRate: todayCompletionPercentage
        )
    }
    
    func weeklyCompletionData() -> [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).reversed().map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let count = areas.reduce(0) { total, area in
                let tasks = area.bowls?.flatMap { $0.tasks ?? [] } ?? []
                let completions = tasks.filter {
                    guard let completedAt = $0.completedAt else { return false }
                    return calendar.startOfDay(for: completedAt) == date
                }.count
                return total + completions
            }
            return (date, count)
        }
    }

    // MARK: - Helpers

    private func isAreaCompletedToday(_ area: Area) -> Bool {
        guard let bowl = area.latestBowl, let completedAt = bowl.completedAt else { return false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.startOfDay(for: completedAt) == today
    }

    /// PRD v1.0: Streak increments ONCE per day on FIRST "start bowl / take photo" action.
    /// NOT on tasks, NOT on verification. Only the first bowl of the day counts.
    private func updateStreakForNewBowl() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = lastPhotoDayTimestamp > 0 ? Date(timeIntervalSince1970: lastPhotoDayTimestamp) : nil
        if let lastDay, calendar.startOfDay(for: lastDay) == today { return }
        streakCount += 1
        lastPhotoDayTimestamp = today.timeIntervalSince1970
    }

    private var bowlsStartedToday: [AreaBowl] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return areas
            .compactMap { $0.bowls }
            .flatMap { $0 }
            .filter { calendar.startOfDay(for: $0.createdAt) == today }
    }

    private var bowlsCompletedToday: [AreaBowl] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return areas
            .compactMap { $0.bowls }
            .flatMap { $0 }
            .filter { bowl in
                guard let completedAt = bowl.completedAt else { return false }
                return calendar.startOfDay(for: completedAt) == today
            }
    }

    private var bowlsVerifiedToday: [AreaBowl] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return areas
            .compactMap { $0.bowls }
            .flatMap { $0 }
            .filter { bowl in
                guard let verifiedAt = bowl.verifiedAt else { return false }
                return calendar.startOfDay(for: verifiedAt) == today && bowl.verificationOutcome == .passed
            }
    }

    private var canStartBowlToday: Bool {
        dailyBowlTarget <= 0 ? false : bowlsCompletedTodayCount < dailyBowlTarget
    }

    /// PRD v1.0: Golden eligibility is DETERMINISTIC (NOT random).
    /// Eligible if:
    /// - (no successful verification in last 7 days) OR
    /// - (completed bowls today < daily target)
    func isGoldenEligible() -> Bool {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date.distantPast
        let hasRecentSuccess = areas
            .compactMap { $0.bowls }
            .flatMap { $0 }
            .contains { bowl in
                guard bowl.verificationOutcome == .passed, let verifiedAt = bowl.verifiedAt else { return false }
                return verifiedAt >= sevenDaysAgo
            }
        return !hasRecentSuccess || bowlsCompletedTodayCount < dailyBowlTarget
    }

    private func updateBowlCompletionState(_ bowl: AreaBowl) {
        if bowl.isCompleted {
            if bowl.completedAt == nil {
                bowl.completedAt = Date()
            }
        } else {
            bowl.completedAt = nil
        }
    }

    /// PRD v1.0: Scoring rules.
    /// Base points earned immediately per task tick (default 1 each).
    /// No verify keeps base only (1×).
    /// Blue: pass 4×base, fail 2.5×base
    /// Golden: pass 10×base, fail 5.5×base
    private func updateBowlTotals(_ bowl: AreaBowl) {
        let base = Double(bowl.basePoints)
        let multiplier: Double
        switch bowl.verificationOutcome {
        case .passed:
            multiplier = bowl.verificationTier == .golden ? 10 : 4
        case .failed:
            multiplier = bowl.verificationTier == .golden ? 5.5 : 2.5
        case .pending, .skipped:
            multiplier = 1
        }
        bowl.bonusMultiplier = multiplier
        bowl.totalPoints = base * multiplier
    }

    private func genericTaskTemplates() -> [String] {
        [
            "Clear visible surfaces",
            "Put loose items away",
            "Wipe one surface",
            "Collect trash",
            "Reset the area"
        ]
    }

    private func fallbackDreamAssetName(for persona: BabciaPersona) -> String {
        switch persona {
        case .classic:
            return "R1_Classic_Reference_NormalizedFull"
        case .baroness:
            return "R2_Baroness_Reference_NormalizedFull"
        case .warrior:
            return "R3_Warrior_Reference_NormalizedFull"
        case .wellness:
            return "R4_Wellness_Reference_NormalizedFull"
        case .coach:
            return "R5_ToughLifecoach_Reference_NormalizedFull"
        }
    }
}
