//
//  Session.swift
//  BabciaTobiasz
//
//  SwiftData model linking scans, dreams, and tasks into a single session.
//

import Foundation
import SwiftData

/// Verification tier for a session's photo review.
enum VerificationTier: String, Codable, Sendable {
    case blue
    case golden
}

/// SwiftData model for a cleaning session with scan, dream, and verification data.
@Model
final class Session {

    // MARK: - Identity

    /// Unique session identifier.
    @Attribute(.unique) var id: UUID
    /// Session creation timestamp.
    var createdAt: Date

    // MARK: - Relationships

    /// Area this session belongs to.
    @Relationship(deleteRule: .cascade) var area: Area
    /// Tasks generated for this session.
    @Relationship(deleteRule: .cascade) var tasks: [CleaningTask]

    // MARK: - Scan Data

    /// Before photo captured during scan.
    var scanPhotoData: Data?
    /// Generated dream image data (filtered).
    var dreamImageData: Data?

    // MARK: - Verification

    /// After photo captured for verification.
    var verificationPhotoData: Data?
    /// Verification tier when requested.
    var verificationTier: VerificationTier?
    /// Verification pass/fail state.
    var verificationPassed: Bool?

    // MARK: - Scoring

    /// Sum of task base points earned.
    var basePoints: Int
    /// Bonus points earned from verification.
    var bonusPoints: Int
    /// Total points including bonus.
    var totalPoints: Int { basePoints + bonusPoints }

    // MARK: - State

    /// True when all tasks are completed.
    var isCompleted: Bool
    /// True once verification has been completed.
    var isVerified: Bool { verificationTier != nil && verificationPassed != nil }

    // MARK: - Initialization

    /// Creates a new session model.
    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        area: Area,
        scanPhotoData: Data? = nil,
        dreamImageData: Data? = nil,
        tasks: [CleaningTask] = [],
        basePoints: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.area = area
        self.scanPhotoData = scanPhotoData
        self.dreamImageData = dreamImageData
        self.tasks = tasks
        self.basePoints = basePoints
        self.bonusPoints = 0
        self.isCompleted = false
    }
}
