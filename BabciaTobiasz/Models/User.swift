//
//  User.swift
//  BabciaTobiasz
//
//  SwiftData model representing the current user and point balances.
//

import Foundation
import SwiftData

/// SwiftData model for user progression and points.
@MainActor
@Model
final class User: @unchecked Sendable {

    /// Unique user identifier.
    @Attribute(.unique) var id: UUID
    /// Total points currently available to spend.
    var potBalance: Int
    /// Total points earned across the lifetime of the user.
    var lifetimePierogis: Int
    /// Current day streak count.
    var currentStreak: Int
    /// Daily target for sessions.
    var dailyTarget: Int

    /// Creates a new user model.
    init(
        id: UUID = UUID(),
        potBalance: Int = 0,
        lifetimePierogis: Int = 0,
        currentStreak: Int = 0,
        dailyTarget: Int = 1
    ) {
        self.id = id
        self.potBalance = potBalance
        self.lifetimePierogis = lifetimePierogis
        self.currentStreak = currentStreak
        self.dailyTarget = dailyTarget
    }
}
