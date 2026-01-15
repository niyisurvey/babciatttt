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

enum BabciaPersona: String, Codable, CaseIterable, Identifiable {
    case classic
    case baroness
    case warrior
    case wellness
    case coach

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: return "Classic Babcia"
        case .baroness: return "The Baroness"
        case .warrior: return "Warrior Babcia"
        case .wellness: return "Wellness-X"
        case .coach: return "Tough Life Coach"
        }
    }

    var tagline: String {
        switch self {
        case .classic: return "My dear… come, we tidy."
        case .baroness: return "This is beneath us."
        case .warrior: return "DEFEAT THE CLUTTER."
        case .wellness: return "Restore harmony."
        case .coach: return "Do it anyway."
        }
    }

    var dreamVisionPrompt: String {
        DreamPromptOverrides.prompt(for: self) ?? ""
    }

    // Added 2026-01-14 22:55 GMT
    var voiceGuidance: String {
        switch self {
        case .classic:
            return "Speak like a loving Polish grandmother. Use 'Oj' and gentle guilt. Mention that you brought food. Be warm but notice everything."
        case .baroness:
            return "Speak with refined aristocratic disappointment. Use 'darling' and subtle shade."
        case .warrior:
            return "Speak like a battle commander. Use caps for emphasis. Treat cleaning as an epic quest."
        case .wellness:
            return "Speak like a calm robot companion. Use 'initiating' and 'protocol'."
        case .coach:
            return "Speak like an efficient office manager. Be direct, slightly exasperated."
        }
    }

    // Added 2026-01-14 22:02 GMT
    var headshotImageName: String {
        switch self {
        case .classic: return "R1_Classic_Headshot_Neutral"
        case .baroness: return "R2_Baroness_Headshot_Neutral"
        case .warrior: return "R3_Warrior_Headshot_Neutral"
        case .wellness: return "R4_Wellness_Headshot_Neutral"
        case .coach: return "R5_ToughLifecoach_Headshot_Neutral"
        }
    }
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
    var personaRaw: String

    @Relationship(deleteRule: .cascade)
    var bowls: [AreaBowl]?

    init(
        name: String,
        description: String? = nil,
        iconName: String = "square.grid.2x2.fill",
        colorHex: String = "#2DD4BF",
        dreamImageName: String? = nil,
        persona: BabciaPersona = .classic
    ) {
        self.id = UUID()
        self.name = name
        self.areaDescription = description
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = Date()
        self.dreamImageName = dreamImageName
        self.personaRaw = persona.rawValue
        self.bowls = []
    }

    var color: Color {
        Color(hex: colorHex) ?? .teal
    }

    var persona: BabciaPersona {
        get { BabciaPersona(rawValue: personaRaw) ?? .classic }
        set { personaRaw = newValue.rawValue }
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
    var beforePhotoData: Data?
    var afterPhotoData: Data?
    var dreamHeroImageData: Data?
    var dreamRawImageData: Data?
    var dreamFilterId: String?
    var dreamGeneratedAt: Date?

    var area: Area?

    @Relationship(deleteRule: .cascade)
    var tasks: [CleaningTask]?

    init(
        createdAt: Date = Date(),
        verificationRequested: Bool = false,
        beforePhotoData: Data? = nil
    ) {
        self.id = UUID()
        self.createdAt = createdAt
        self.verificationRequested = verificationRequested
        self.verificationTierRaw = BowlVerificationTier.none.rawValue
        self.verificationOutcomeRaw = verificationRequested ? BowlVerificationOutcome.pending.rawValue : BowlVerificationOutcome.skipped.rawValue
        self.basePoints = 0
        self.bonusMultiplier = 1
        self.totalPoints = 0
        self.beforePhotoData = beforePhotoData
        self.afterPhotoData = nil
        self.dreamHeroImageData = nil
        self.dreamRawImageData = nil
        self.dreamFilterId = nil
        self.dreamGeneratedAt = nil
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
            Area(name: "Kitchen Table", description: "Where I eat", iconName: "cup.and.saucer.fill", colorHex: "#2DD4BF", persona: .classic),
            Area(name: "Bedroom", description: "Sleep + reset", iconName: "bed.double.fill", colorHex: "#7C3AED", persona: .baroness)
        ]
    }
}
