//
//  HomeViewModel.swift
//  BabciaTobiasz
//
//  Created 2026-01-15 (Claude Code - Phase 1.1)
//  Home dashboard data aggregation
//

import SwiftUI
import SwiftData
import Observation

@MainActor
@Observable
final class HomeViewModel {
    // Dashboard data
    var potBalance: Int = 0
    var currentStreak: Int = 0
    var dailyProgress: Int = 0
    var dailyTarget: Int = 1
    var lifetimePierogis: Int = 0
    var latestDreamImageData: Data? = nil
    var totalCompletions: Int = 0
    var topDayLabel: String = "—"
    var topDayCount: Int = 0
    var topHourLabel: String = "—"
    var topHourCount: Int = 0

    // State
    var isLoading: Bool = false
    var showError: Bool = false
    var errorMessage: String? = nil

    // Dependencies
    private let homeDataService: HomeDataService
    private let user: User

    init(homeDataService: HomeDataService, user: User) {
        self.homeDataService = homeDataService
        self.user = user
    }

    /// Fetch all dashboard data for the current user
    func fetchDashboardData() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let data = try await homeDataService.fetchDashboardData(for: user)

            // Update published properties
            potBalance = data.potBalance
            currentStreak = data.currentStreak
            dailyProgress = data.dailyProgress
            dailyTarget = data.dailyTarget
            lifetimePierogis = data.lifetimePierogis
            latestDreamImageData = data.latestDreamImage
            totalCompletions = data.patternSummary.totalCompletions
            topDayLabel = data.patternSummary.topDayLabel
            topDayCount = data.patternSummary.topDayCount
            topHourLabel = data.patternSummary.topHourLabel
            topHourCount = data.patternSummary.topHourCount
        } catch {
            showError(message: "Failed to load dashboard: \(error.localizedDescription)")
        }
    }

    // MARK: - Error Handling

    private func showError(message: String) {
        errorMessage = message
        showError = true
    }

    func dismissError() {
        showError = false
        errorMessage = nil
    }
}
