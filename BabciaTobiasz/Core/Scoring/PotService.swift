//
//  PotService.swift
//  BabciaTobiasz
//
//  Handles immediate updates to the user's points balance.
//

import Foundation
import SwiftData

/// Errors thrown by PotService when point operations fail.
enum PotError: Error, Sendable {
    case insufficientBalance
    case invalidAmount
    case persistenceFailure
}

/// Service responsible for updating the user's points pot.
@MainActor
final class PotService {
    private let modelContext: ModelContext

    /// Creates a new pot service.
    /// - Parameter modelContext: ModelContext used for persistence.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Adds points to the user's pot and lifetime total.
    /// - Parameters:
    ///   - points: Points to add.
    ///   - user: User to update.
    func addPoints(_ points: Int, to user: User) throws {
        guard points >= 0 else { throw PotError.invalidAmount }
        user.potBalance += points
        user.lifetimePierogis += points
        do {
            try modelContext.save()
        } catch {
            throw PotError.persistenceFailure
        }
    }

    /// Spends points from the user's pot.
    /// - Parameters:
    ///   - points: Points to spend.
    ///   - user: User to update.
    func spendPoints(_ points: Int, from user: User) throws {
        guard points >= 0 else { throw PotError.invalidAmount }
        guard user.potBalance >= points else {
            throw PotError.insufficientBalance
        }
        user.potBalance -= points
        do {
            try modelContext.save()
        } catch {
            throw PotError.persistenceFailure
        }
    }

    /// Removes points from the user's pot and lifetime total (used for undo flows).
    /// - Parameters:
    ///   - points: Points to remove.
    ///   - user: User to update.
    func revokePoints(_ points: Int, from user: User) throws {
        guard points >= 0 else { throw PotError.invalidAmount }
        user.potBalance = max(0, user.potBalance - points)
        user.lifetimePierogis = max(0, user.lifetimePierogis - points)
        do {
            try modelContext.save()
        } catch {
            throw PotError.persistenceFailure
        }
    }
}
