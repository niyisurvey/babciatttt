//
//  GoldenEligibilityService.swift
//  BabciaTobiasz
//
//  Determines deterministic eligibility for Golden verification.
//

import Foundation

/// Service to determine Golden verification eligibility.
@MainActor
final class GoldenEligibilityService {

    /// Returns true if the user is eligible for Golden verification.
    /// - Parameters:
    ///   - user: User state including daily target.
    ///   - recentSessions: Sessions to consider for verification history.
    func isEligibleForGolden(user: User, recentSessions: [Session]) -> Bool {
        let daysSinceLastVerification = calculateDaysSinceLastVerification(sessions: recentSessions)
        let isBehindDailyTarget = calculateDailyProgress(user: user, sessions: recentSessions) < user.dailyTarget

        return daysSinceLastVerification >= 3 || isBehindDailyTarget
    }

    private func calculateDaysSinceLastVerification(sessions: [Session]) -> Int {
        let lastVerifiedSession = sessions
            .filter { $0.isVerified }
            .sorted { $0.createdAt > $1.createdAt }
            .first

        guard let lastDate = lastVerifiedSession?.createdAt else {
            return Int.max
        }

        return Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
    }

    private func calculateDailyProgress(user: User, sessions: [Session]) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let todaySessions = sessions.filter { Calendar.current.isDate($0.createdAt, inSameDayAs: today) }
        return todaySessions.count
    }
}
