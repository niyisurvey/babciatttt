//
//  HomeDataService.swift
//  BabciaTobiasz
//
//  Aggregates dashboard data for the Home hub.
//

import Foundation
import SwiftData

/// Data payload for the Home dashboard.
struct DashboardData: Sendable {
    let potBalance: Int
    let currentStreak: Int
    let dailyProgress: Int
    let dailyTarget: Int
    let lifetimePierogis: Int
    let latestDreamImage: Data?
    let patternSummary: CompletionPatternSummary
}

struct CompletionPatternSummary: Sendable {
    let totalCompletions: Int
    let topDayLabel: String
    let topDayCount: Int
    let topHourLabel: String
    let topHourCount: Int
}

/// Service to fetch dashboard data for the Home screen.
@MainActor
final class HomeDataService {
    private let modelContext: ModelContext

    /// Creates a new Home data service.
    /// - Parameter modelContext: ModelContext used for persistence reads.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Fetches aggregated dashboard data for the provided user.
    /// - Parameter user: User whose data should be returned.
    func fetchDashboardData(for user: User) async throws -> DashboardData {
        let todaySessions = try fetchTodaySessions()
        let latestDream = try fetchLatestDreamImage()
        let patternSummary = try fetchCompletionPatternSummary()

        return DashboardData(
            potBalance: user.potBalance,
            currentStreak: user.currentStreak,
            dailyProgress: todaySessions.count,
            dailyTarget: user.dailyTarget,
            lifetimePierogis: user.lifetimePierogis,
            latestDreamImage: latestDream,
            patternSummary: patternSummary
        )
    }

    private func fetchTodaySessions() throws -> [Session] {
        let today = Calendar.current.startOfDay(for: Date())
        let descriptor = FetchDescriptor<Session>(
            predicate: #Predicate { session in
                session.createdAt >= today
            }
        )
        return try modelContext.fetch(descriptor)
    }

    private func fetchLatestDreamImage() throws -> Data? {
        var descriptor = FetchDescriptor<Session>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let latest = try modelContext.fetch(descriptor).first
        return latest?.dreamImageData
    }

    private func fetchCompletionPatternSummary() throws -> CompletionPatternSummary {
        let descriptor = FetchDescriptor<TaskCompletionEvent>(
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )
        let events = try modelContext.fetch(descriptor)
        guard !events.isEmpty else {
            return CompletionPatternSummary(
                totalCompletions: 0,
                topDayLabel: "—",
                topDayCount: 0,
                topHourLabel: "—",
                topHourCount: 0
            )
        }

        var dayCounts = Array(repeating: 0, count: 7)
        var hourCounts = Array(repeating: 0, count: 24)

        for event in events {
            let dayIndex = max(1, min(7, event.dayOfWeek)) - 1
            dayCounts[dayIndex] += 1
            let hourIndex = max(0, min(23, event.hourOfDay))
            hourCounts[hourIndex] += 1
        }

        let topDayIndex = dayCounts.indices.max(by: { dayCounts[$0] < dayCounts[$1] }) ?? 0
        let topHourIndex = hourCounts.indices.max(by: { hourCounts[$0] < hourCounts[$1] }) ?? 0
        let dayLabel = Calendar.current.shortWeekdaySymbols[topDayIndex]
        let hourLabel = String(format: "%02d:00", topHourIndex)

        return CompletionPatternSummary(
            totalCompletions: events.count,
            topDayLabel: dayLabel,
            topDayCount: dayCounts[topDayIndex],
            topHourLabel: hourLabel,
            topHourCount: hourCounts[topHourIndex]
        )
    }
}
