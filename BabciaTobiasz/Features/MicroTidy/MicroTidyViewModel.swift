//
//  MicroTidyViewModel.swift
//  BabciaTobiasz
//

import Foundation
import SwiftData

@MainActor
@Observable
final class MicroTidyViewModel {
    var areas: [Area] = []
    var selectedArea: Area?
    var isLoading: Bool = false
    var errorMessage: String?
    var showError: Bool = false
    var lastResponse: String?
    var dailyCount: Int = 0

    private var persistenceService: PersistenceService?
    private var potService: PotService?
    private var currentUser: User?
    private let configService: AppConfigService
    @ObservationIgnored private let userDefaults: UserDefaults
    @ObservationIgnored private let calendar: Calendar

    private enum StorageKeys {
        static let microTidyCount = "microTidy.dailyCount"
        static let microTidyDate = "microTidy.dayStart"
    }

    init(
        configService: AppConfigService = .shared,
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current
    ) {
        self.configService = configService
        self.userDefaults = userDefaults
        self.calendar = calendar
        refreshDailyState()
    }

    func configure(modelContext: ModelContext) {
        let persistence = PersistenceService(modelContext: modelContext)
        persistenceService = persistence
        potService = PotService(modelContext: modelContext)
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
            selectDefaultArea()
        } catch {
            handleError(error)
        }
    }

    func pickRandomArea() {
        guard areas.count > 1 else { return }
        selectedArea = areas.randomElement()
    }

    func canDoMicroTidy() -> Bool {
        refreshDailyState()
        return dailyCount < configService.microTidyLimit
    }

    func completeMicroTidy() {
        guard canDoMicroTidy() else { return }
        refreshDailyState()
        dailyCount += 1
        persistDailyState()
        awardPoints()
        lastResponse = configService.getNextBabciaResponse()
    }

    var microTidyLimit: Int { configService.microTidyLimit }
    var microTidyPoints: Int { configService.microTidyPoints }

    private func selectDefaultArea() {
        if areas.count == 1 {
            selectedArea = areas.first
        } else if areas.count > 1 {
            pickRandomArea()
        } else {
            selectedArea = nil
        }
    }

    private func refreshDailyState() {
        let today = calendar.startOfDay(for: Date())
        let storedTimestamp = userDefaults.double(forKey: StorageKeys.microTidyDate)
        if storedTimestamp == 0 {
            dailyCount = 0
            userDefaults.set(today.timeIntervalSince1970, forKey: StorageKeys.microTidyDate)
            userDefaults.set(0, forKey: StorageKeys.microTidyCount)
            return
        }

        let storedDate = Date(timeIntervalSince1970: storedTimestamp)
        if calendar.isDate(storedDate, inSameDayAs: today) {
            dailyCount = userDefaults.integer(forKey: StorageKeys.microTidyCount)
        } else {
            dailyCount = 0
            userDefaults.set(today.timeIntervalSince1970, forKey: StorageKeys.microTidyDate)
            userDefaults.set(0, forKey: StorageKeys.microTidyCount)
        }
    }

    private func persistDailyState() {
        let today = calendar.startOfDay(for: Date())
        userDefaults.set(today.timeIntervalSince1970, forKey: StorageKeys.microTidyDate)
        userDefaults.set(dailyCount, forKey: StorageKeys.microTidyCount)
    }

    private func awardPoints() {
        guard let potService, let currentUser else { return }
        do {
            try potService.addPoints(configService.microTidyPoints, to: currentUser)
        } catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Error) {
        errorMessage = error.localizedDescription
        showError = true
    }
}
