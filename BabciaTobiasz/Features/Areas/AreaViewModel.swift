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
    @ObservationIgnored private let userDefaults = UserDefaults.standard

    private enum StorageKeys {
        static let dailyBowlTarget = "dailyBowlTarget"
        static let streakCount = "streakCount"
        static let lastPhotoDayTimestamp = "lastPhotoDayTimestamp"
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

    var hasVerifiedToday: Bool {
        !bowlsVerifiedToday.isEmpty
    }

    var hasCompletedUnverifiedToday: Bool {
        bowlsCompletedToday.contains { $0.verificationOutcome != .passed }
    }
    
    // MARK: - Initialization
    
    init(persistenceService: PersistenceService? = nil, notificationService: NotificationService? = nil) {
        self.persistenceService = persistenceService
        self.notificationService = notificationService
        loadPersistentState()
    }
    
    // MARK: - Configuration
    
    func configure(persistenceService: PersistenceService, notificationService: NotificationService) {
        self.persistenceService = persistenceService
        self.notificationService = notificationService
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
        dreamImageName: String? = nil
    ) async {
        guard let persistenceService = persistenceService else { return }
        
        let area = Area(
            name: name,
            description: description,
            iconName: iconName,
            colorHex: colorHex,
            dreamImageName: dreamImageName
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
    
    func startBowl(for area: Area, verificationRequested: Bool) {
        guard let persistenceService = persistenceService else { return }

        guard canStartBowlToday else {
            errorMessage = "Kitchen Closed. Daily target reached."
            showError = true
            return
        }

        guard area.inProgressBowl == nil else { return }

        let tasks = genericTaskTemplates().prefix(5).map { CleaningTask(title: $0) }

        do {
            let bowl = try persistenceService.createBowl(
                for: area,
                tasks: Array(tasks),
                verificationRequested: verificationRequested
            )
            if verificationRequested {
                bowl.verificationRequestedAt = Date()
            }
            updateStreakForNewBowl()
            try persistenceService.save()
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
    
    func finalizeVerification(for bowl: AreaBowl, tier: BowlVerificationTier, outcome: BowlVerificationOutcome) {
        guard let persistenceService = persistenceService else { return }
        do {
            bowl.verificationTier = tier
            bowl.verificationOutcome = outcome
            bowl.verifiedAt = Date()
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
        dailyBowlTarget <= 0 ? false : bowlsStartedTodayCount < dailyBowlTarget
    }

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
}
