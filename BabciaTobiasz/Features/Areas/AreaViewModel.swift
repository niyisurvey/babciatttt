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
    var navigationPath: NavigationPath = NavigationPath()
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
    private var reminderScheduler: ReminderSchedulerProtocol?
    // Added 2026-01-14 22:55 GMT
    private var scanPipelineService: BabciaScanPipelineService?
    private var potService: PotService?
    private var currentUser: User?
    private var progressionService: ProgressionServiceProtocol?
    private let verificationJudge: VerificationJudgeProtocol
    private let scoringService: ScoringService
    @ObservationIgnored private let userDefaults = UserDefaults.standard
    @ObservationIgnored private var pendingReminderAreaId: UUID?

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

    func milestone(for area: Area) -> MilestoneDisplay? {
        progressionService?.getMilestone(for: area)
    }
    
    // MARK: - Initialization
    
    init(
        persistenceService: PersistenceService? = nil,
        reminderScheduler: ReminderSchedulerProtocol? = nil,
        scanPipelineService: BabciaScanPipelineService? = nil,
        potService: PotService? = nil,
        currentUser: User? = nil,
        progressionService: ProgressionServiceProtocol? = nil,
        verificationJudge: VerificationJudgeProtocol? = nil,
        scoringService: ScoringService? = nil
    ) {
        self.persistenceService = persistenceService
        self.reminderScheduler = reminderScheduler
        self.scanPipelineService = scanPipelineService
        self.potService = potService
        self.currentUser = currentUser
        self.progressionService = progressionService
        self.verificationJudge = verificationJudge ?? VerificationJudgeService()
        self.scoringService = scoringService ?? ScoringService()
        loadPersistentState()
    }
    
    // MARK: - Configuration
    
    func configure(
        persistenceService: PersistenceService,
        reminderScheduler: ReminderSchedulerProtocol,
        // Added 2026-01-14 22:55 GMT
        scanPipelineService: BabciaScanPipelineService,
        potService: PotService? = nil,
        currentUser: User? = nil,
        progressionService: ProgressionServiceProtocol? = nil
    ) {
        self.persistenceService = persistenceService
        self.reminderScheduler = reminderScheduler
        self.scanPipelineService = scanPipelineService
        self.potService = potService
        self.currentUser = currentUser
        self.progressionService = progressionService

        if let progressionService = progressionService as? ProgressionService,
           let potService,
           let currentUser {
            progressionService.configureAwardHandler { points in
                try potService.addPoints(points, to: currentUser)
            }
        }
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
            reminderScheduler?.cancelAll(for: area.id)
            try persistenceService.deleteReminderConfig(for: area.id)
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

            let scanResult = await runScan(beforePhotoData: beforePhotoData, persona: area.persona)

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

    func startTasksOnlyBowl(for area: Area, beforePhotoData: Data?) async {
        guard let persistenceService = persistenceService else { return }

        guard canStartBowlToday else {
            errorMessage = "Kitchen Closed. Daily target reached."
            showError = true
            return
        }

        guard area.inProgressBowl == nil else {
            errorMessage = "Finish the current session before starting a new scan."
            showError = true
            return
        }

        guard let beforePhotoData else {
            errorMessage = "Scan photo required to start a session."
            showError = true
            return
        }

        do {
            isLoading = true
            dreamStatusMessage = "Scanning..."
            defer {
                isLoading = false
            }

            let scanResult = await runScan(beforePhotoData: beforePhotoData, persona: area.persona)
            let tasks = scanResult.tasks.prefix(5).map { CleaningTask(title: $0) }
            let bowl = try persistenceService.createBowl(
                for: area,
                tasks: Array(tasks),
                verificationRequested: false,
                beforePhotoData: beforePhotoData
            )

            bowl.dreamHeroImageData = nil
            bowl.dreamRawImageData = nil
            bowl.dreamFilterId = nil
            bowl.dreamGeneratedAt = nil
            dreamStatusMessage = "Tasks refreshed."

            updateStreakForNewBowl()
            try persistenceService.save()

            if let taskError = scanResult.taskErrorMessage, !taskError.isEmpty {
                errorMessage = taskError
                showError = true
            }
        } catch {
            handleError(error)
        }
    }

    func appendTasks(for area: Area, beforePhotoData: Data?) async {
        guard let persistenceService = persistenceService else { return }

        guard let beforePhotoData else {
            errorMessage = "Scan photo required to append tasks."
            showError = true
            return
        }

        guard let bowl = area.inProgressBowl else {
            errorMessage = "No active session to append tasks."
            showError = true
            return
        }

        do {
            isLoading = true
            dreamStatusMessage = "Scanning..."
            defer {
                isLoading = false
            }

            let scanResult = await runScan(beforePhotoData: beforePhotoData, persona: area.persona)
            let tasks = scanResult.tasks.prefix(5).map { CleaningTask(title: $0) }
            if bowl.tasks == nil {
                bowl.tasks = []
            }
            for task in tasks {
                task.bowl = bowl
                bowl.tasks?.append(task)
                persistenceService.insert(task)
            }
            dreamStatusMessage = "Tasks appended."
            try persistenceService.save()

            if let taskError = scanResult.taskErrorMessage, !taskError.isEmpty {
                errorMessage = taskError
                showError = true
            }
        } catch {
            handleError(error)
        }
    }

    private func runScan(beforePhotoData: Data, persona: BabciaPersona) async -> BabciaScanPipelineOutput {
        let fallbackTasks = Array(genericTaskTemplates().prefix(5))
        return await scanPipelineService?.runScan(
            beforePhotoData: beforePhotoData,
            persona: persona,
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
    }
    
    func toggleTaskCompletion(_ task: CleaningTask) {
        guard let persistenceService = persistenceService else { return }
        do {
            guard let bowl = task.bowl else { return }
            guard !task.isCompleted else { return }
            let completionDate = Date()
            task.completedAt = completionDate
            bowl.basePoints += task.points
            recordTaskCompletion(task, bowl: bowl, completionDate: completionDate)
            if let potService, let currentUser {
                do {
                    try potService.addPoints(task.points, to: currentUser)
                } catch {
                    handleError(error)
                }
            }
            updateBowlCompletionState(bowl)
            updateBowlTotals(bowl)
            try persistenceService.save()
        } catch {
            handleError(error)
        }
    }

    private func recordTaskCompletion(_ task: CleaningTask, bowl: AreaBowl, completionDate: Date) {
        guard let persistenceService = persistenceService else { return }
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: completionDate)
        let hourOfDay = calendar.component(.hour, from: completionDate)
        let areaName = bowl.area?.name ?? ""
        let personaRaw = bowl.area?.personaRaw ?? BabciaPersona.classic.rawValue
        let event = TaskCompletionEvent(
            completedAt: completionDate,
            dayOfWeek: dayOfWeek,
            hourOfDay: hourOfDay,
            taskTitle: task.title,
            taskPoints: task.points,
            areaId: bowl.area?.id,
            areaName: areaName,
            personaRaw: personaRaw,
            bowlId: bowl.id
        )
        persistenceService.insert(event)
    }

    /// Judges and applies verification results for a completed bowl.
    /// - Parameters:
    ///   - bowl: Bowl to verify.
    ///   - tier: Verification tier used.
    ///   - afterPhotoData: JPEG data captured after cleaning.
    /// - Returns: `true` if verification passed.
    /// - Throws: `VerificationJudgeError` if judging fails.
    func submitVerification(
        for bowl: AreaBowl,
        tier: BowlVerificationTier,
        afterPhotoData: Data
    ) async throws -> Bool {
        do {
            guard let persistenceService = persistenceService else {
                throw VerificationJudgeError.judgingFailed(reason: "Persistence unavailable")
            }
            guard let beforePhotoData = bowl.beforePhotoData else {
                throw VerificationJudgeError.invalidPhotoData
            }
            let passed = try await verificationJudge.judge(
                beforePhoto: beforePhotoData,
                afterPhoto: afterPhotoData
            )
            try applyVerificationResult(
                to: bowl,
                tier: tier,
                passed: passed,
                afterPhotoData: afterPhotoData,
                persistenceService: persistenceService
            )
            return passed
        } catch let error as VerificationJudgeError {
            throw error
        } catch {
            throw VerificationJudgeError.judgingFailed(reason: error.localizedDescription)
        }
    }

    func finalizeVerification(for bowl: AreaBowl, tier: BowlVerificationTier, outcome: BowlVerificationOutcome, afterPhotoData: Data?) {
        guard let persistenceService = persistenceService else { return }
        do {
            if bowl.verificationRequested == false {
                bowl.verificationRequested = true
                bowl.verificationRequestedAt = Date()
            }
            let wasVerified = bowl.verifiedAt != nil
            bowl.verificationTier = tier
            bowl.verificationOutcome = outcome
            bowl.verifiedAt = Date()
            if let afterPhotoData {
                bowl.afterPhotoData = afterPhotoData
            }
            updateBowlTotals(bowl)
            try applyPotBonusIfNeeded(for: bowl, wasVerified: wasVerified)
            try persistenceService.save()
        } catch {
            handleError(error)
        }
    }

    func markVerificationDecisionPending(for bowl: AreaBowl) {
        guard let persistenceService = persistenceService else { return }
        do {
            bowl.verificationRequested = true
            bowl.verificationRequestedAt = Date()
            bowl.verificationOutcome = .pending
            updateBowlTotals(bowl)
            try persistenceService.save()
        } catch {
            handleError(error)
        }
    }

    func skipVerification(for bowl: AreaBowl) {
        guard let persistenceService = persistenceService else { return }
        do {
            bowl.verificationRequested = false
            bowl.verificationOutcome = .skipped
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

    // MARK: - Navigation

    func openAreaFromReminder(_ areaId: UUID) {
        if areas.isEmpty {
            loadAreas()
        }
        pendingReminderAreaId = areaId
        navigationPath = NavigationPath()
        navigationPath.append(areaId)
    }

    func consumeReminderPrompt(for areaId: UUID) -> Bool {
        guard pendingReminderAreaId == areaId else { return false }
        pendingReminderAreaId = nil
        return true
    }

    func area(for areaId: UUID) -> Area? {
        areas.first { $0.id == areaId }
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
    /// - (no successful verification in last 3 days) OR
    /// - (completed bowls today < daily target)
    func isGoldenEligible() -> Bool {
        let calendar = Calendar.current
        let lastVerifiedAt = areas
            .compactMap { $0.bowls }
            .flatMap { $0 }
            .filter { $0.verificationOutcome == .passed }
            .compactMap { $0.verifiedAt }
            .sorted(by: >)
            .first

        let daysSinceLastVerification: Int
        if let lastVerifiedAt {
            daysSinceLastVerification = calendar.dateComponents([.day], from: lastVerifiedAt, to: Date()).day ?? 0
        } else {
            daysSinceLastVerification = Int.max
        }

        return daysSinceLastVerification >= 3 || bowlsCompletedTodayCount < dailyBowlTarget
    }

    private func updateBowlCompletionState(_ bowl: AreaBowl) {
        if bowl.isCompleted {
            if bowl.completedAt == nil {
                bowl.completedAt = Date()
                if let area = bowl.area {
                    Task { await progressionService?.awardBonus(for: area) }
                }
            }
        } else {
            bowl.completedAt = nil
        }
    }

    /// Applies verification scoring to update total points.
    private func updateBowlTotals(_ bowl: AreaBowl) {
        switch bowl.verificationOutcome {
        case .passed:
            let totals = scoreBowlTotals(for: bowl, passed: true)
            bowl.bonusMultiplier = totals.bonusMultiplier
            bowl.totalPoints = Double(totals.totalPoints)
        case .failed:
            let totals = scoreBowlTotals(for: bowl, passed: false)
            bowl.bonusMultiplier = totals.bonusMultiplier
            bowl.totalPoints = Double(totals.totalPoints)
        case .pending, .skipped:
            bowl.bonusMultiplier = 1
            bowl.totalPoints = Double(bowl.basePoints)
        }
    }

    private func scoreBowlTotals(for bowl: AreaBowl, passed: Bool) -> (totalPoints: Int, bonusMultiplier: Double) {
        guard bowl.basePoints > 0 else {
            return (0, 1)
        }
        guard let area = bowl.area, let tier = mapVerificationTier(bowl.verificationTier) else {
            return (bowl.basePoints, 1)
        }
        let session = Session(area: area, basePoints: bowl.basePoints)
        scoringService.applyVerificationBonus(to: session, tier: tier, passed: passed)
        let totalPoints = session.totalPoints
        let bonusMultiplier = Double(totalPoints) / Double(bowl.basePoints)
        return (totalPoints, bonusMultiplier)
    }

    private func mapVerificationTier(_ tier: BowlVerificationTier) -> VerificationTier? {
        switch tier {
        case .blue:
            return .blue
        case .golden:
            return .golden
        case .none:
            return nil
        }
    }

    private func applyVerificationResult(
        to bowl: AreaBowl,
        tier: BowlVerificationTier,
        passed: Bool,
        afterPhotoData: Data,
        persistenceService: PersistenceService
    ) throws {
        if bowl.verificationRequested == false {
            bowl.verificationRequested = true
            bowl.verificationRequestedAt = Date()
        }
        let wasVerified = bowl.verifiedAt != nil
        bowl.verificationTier = tier
        bowl.verificationOutcome = passed ? .passed : .failed
        bowl.verifiedAt = Date()
        bowl.afterPhotoData = afterPhotoData
        updateBowlTotals(bowl)
        try applyPotBonusIfNeeded(for: bowl, wasVerified: wasVerified)
        try persistenceService.save()
    }

    private func applyPotBonusIfNeeded(for bowl: AreaBowl, wasVerified: Bool) throws {
        guard !wasVerified, let potService, let currentUser else { return }
        let bonusPoints = max(0, Int(bowl.totalPoints) - bowl.basePoints)
        guard bonusPoints > 0 else { return }
        try potService.addPoints(bonusPoints, to: currentUser)
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
