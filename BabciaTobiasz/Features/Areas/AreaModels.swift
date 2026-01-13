//
//  AreaModels.swift
//  BabciaTobiasz
//
//  SwiftData models for Babcia areas, bowls, and tasks.
//

import Foundation
import SwiftData
import SwiftUI

enum BowlVerificationTier: String, Codable, CaseIterable {
    case none
    case blue
    case golden
}

enum BowlVerificationOutcome: String, Codable, CaseIterable {
    case pending
    case passed
    case failed
    case skipped
}

@Model
final class Area {
    var id: UUID
    var name: String
    var areaDescription: String?
    var iconName: String
    var colorHex: String
    var createdAt: Date
    var dreamImageName: String?

    @Relationship(deleteRule: .cascade)
    var bowls: [AreaBowl]?

    init(
        name: String,
        description: String? = nil,
        iconName: String = "square.grid.2x2.fill",
        colorHex: String = "#2DD4BF",
        dreamImageName: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.areaDescription = description
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = Date()
        self.dreamImageName = dreamImageName
        self.bowls = []
    }

    var color: Color {
        Color(hex: colorHex) ?? .teal
    }

    var latestBowl: AreaBowl? {
        bowls?.sorted { $0.createdAt > $1.createdAt }.first
    }

    var activeBowl: AreaBowl? {
        latestBowl
    }

    var inProgressBowl: AreaBowl? {
        bowls?.first { !$0.isCompleted }
    }
}

@Model
final class AreaBowl {
    var id: UUID
    var createdAt: Date
    var completedAt: Date?
    var verificationRequested: Bool
    var verificationTierRaw: String
    var verificationOutcomeRaw: String
    var verificationRequestedAt: Date?
    var verifiedAt: Date?
    var basePoints: Int
    var bonusMultiplier: Double
    var totalPoints: Double

    var area: Area?

    @Relationship(deleteRule: .cascade)
    var tasks: [CleaningTask]?

    init(
        createdAt: Date = Date(),
        verificationRequested: Bool = false
    ) {
        self.id = UUID()
        self.createdAt = createdAt
        self.verificationRequested = verificationRequested
        self.verificationTierRaw = BowlVerificationTier.none.rawValue
        self.verificationOutcomeRaw = verificationRequested ? BowlVerificationOutcome.pending.rawValue : BowlVerificationOutcome.skipped.rawValue
        self.basePoints = 0
        self.bonusMultiplier = 1
        self.totalPoints = 0
        self.tasks = []
    }

    var verificationTier: BowlVerificationTier {
        get { BowlVerificationTier(rawValue: verificationTierRaw) ?? .none }
        set { verificationTierRaw = newValue.rawValue }
    }

    var verificationOutcome: BowlVerificationOutcome {
        get { BowlVerificationOutcome(rawValue: verificationOutcomeRaw) ?? .pending }
        set { verificationOutcomeRaw = newValue.rawValue }
    }

    var isCompleted: Bool {
        guard let tasks = tasks, !tasks.isEmpty else { return false }
        return tasks.allSatisfy { $0.isCompleted }
    }

    var isVerified: Bool {
        verificationOutcome == .passed
    }

    var isVerificationPending: Bool {
        verificationRequested && verificationOutcome == .pending
    }
}

@Model
final class CleaningTask {
    var id: UUID
    var title: String
    var detail: String?
    var points: Int
    var createdAt: Date
    var completedAt: Date?
    var bowl: AreaBowl?

    init(title: String, detail: String? = nil, points: Int = 1, createdAt: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.detail = detail
        self.points = points
        self.createdAt = createdAt
    }

    var isCompleted: Bool {
        completedAt != nil
    }
}

extension Area {
    static var sampleAreas: [Area] {
        [
            Area(name: "Kitchen Table", description: "Where I eat", iconName: "cup.and.saucer.fill", colorHex: "#2DD4BF"),
            Area(name: "Bedroom", description: "Sleep + reset", iconName: "bed.double.fill", colorHex: "#7C3AED")
        ]
    }
}
