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

    var localizedDisplayName: String {
        switch self {
        case .classic: return String(localized: "persona.classic.name")
        case .baroness: return String(localized: "persona.baroness.name")
        case .warrior: return String(localized: "persona.warrior.name")
        case .wellness: return String(localized: "persona.wellness.name")
        case .coach: return String(localized: "persona.coach.name")
        }
    }

    var localizedTagline: String {
        switch self {
        case .classic: return String(localized: "persona.classic.tagline")
        case .baroness: return String(localized: "persona.baroness.tagline")
        case .warrior: return String(localized: "persona.warrior.tagline")
        case .wellness: return String(localized: "persona.wellness.tagline")
        case .coach: return String(localized: "persona.coach.tagline")
        }
    }

    var localizedArchetype: String {
        switch self {
        case .classic: return String(localized: "persona.classic.archetype")
        case .baroness: return String(localized: "persona.baroness.archetype")
        case .warrior: return String(localized: "persona.warrior.archetype")
        case .wellness: return String(localized: "persona.wellness.archetype")
        case .coach: return String(localized: "persona.coach.archetype")
        }
    }

    var localizedDescription: String {
        switch self {
        case .classic: return String(localized: "persona.classic.description")
        case .baroness: return String(localized: "persona.baroness.description")
        case .warrior: return String(localized: "persona.warrior.description")
        case .wellness: return String(localized: "persona.wellness.description")
        case .coach: return String(localized: "persona.coach.description")
        }
    }

    var localizedQuote: String {
        switch self {
        case .classic: return String(localized: "persona.classic.quote")
        case .baroness: return String(localized: "persona.baroness.quote")
        case .warrior: return String(localized: "persona.warrior.quote")
        case .wellness: return String(localized: "persona.wellness.quote")
        case .coach: return String(localized: "persona.coach.quote")
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

    var fullBodyHeroImageName: String {
        switch self {
        case .classic: return "R1_Classic_FullBody_Happy"
        case .baroness: return "R2_Baroness_FullBody_Happy"
        case .warrior: return "R3_Warrior_FullBody_Happy"
        case .wellness: return "R4_Wellness_FullBody_Happy"
        case .coach: return "R5_ToughLifecoach_FullBody_Happy"
        }
    }

    func fullBodyImageName(for pose: BabciaPose) -> String {
        switch (self, pose) {
        case (.classic, .happy): return "R1_Classic_FullBody_Happy"
        case (.classic, .victory): return "R1_Classic_FullBody_Victory"
        case (.classic, .sadDisappointed): return "R1_Classic_FullBody_SadDisappointed"
        case (.baroness, .happy): return "R2_Baroness_FullBody_Happy"
        case (.baroness, .victory): return "R2_Baroness_FullBody_Victory"
        case (.baroness, .sadDisappointed): return "R2_Baroness_FullBody_SadDisappointed"
        case (.warrior, .happy): return "R3_Warrior_FullBody_Happy"
        case (.warrior, .victory): return "R3_Warrior_FullBody_Victory"
        case (.warrior, .sadDisappointed): return "R3_Warrior_FullBody_SadDisappointed"
        case (.wellness, .happy): return "R4_Wellness_FullBody_Happy"
        case (.wellness, .victory): return "R4_Wellness_FullBody_Victory"
        case (.wellness, .sadDisappointed): return "R4_Wellness_FullBody_SadDisappointed"
        case (.coach, .happy): return "R5_ToughLifecoach_FullBody_Happy"
        case (.coach, .victory): return "R5_ToughLifecoach_FullBody_Victory"
        case (.coach, .sadDisappointed): return "R5_ToughLifecoach_FullBody_SadDisappointed"
        }
    }

    var portraitThinkingImageName: String {
        switch self {
        case .classic: return "R1_Classic_Portrait_Thinking"
        case .baroness: return "R2_Baroness_Portrait_Thinking"
        case .warrior: return "R3_Warrior_Portrait_Thinking"
        case .wellness: return "R4_Wellness_Portrait_Thinking"
        case .coach: return "R5_ToughLifecoach_Portrait_Thinking"
        }
    }

    var portraitSadImageName: String {
        switch self {
        case .classic: return "R1_Classic_Portrait_SadDisappointed"
        case .baroness: return "R2_Baroness_Portrait_SadDisappointed"
        case .warrior: return "R3_Warrior_Portrait_SadDisappointed"
        case .wellness: return "R4_Wellness_Portrait_SadDisappointed"
        case .coach: return "R5_ToughLifecoach_Portrait_SadDisappointed"
        }
    }
}

enum BabciaPose {
    case happy
    case victory
    case sadDisappointed
}

extension BabciaPose {
    static func dailyRotation(for date: Date, calendar: Calendar = .current) -> BabciaPose {
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 1
        let poses: [BabciaPose] = [.happy, .victory, .sadDisappointed]
        return poses[(dayOfYear - 1) % poses.count]
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
    var streamingCameraId: UUID?

    @Relationship(deleteRule: .cascade)
    var bowls: [AreaBowl]?

    init(
        name: String,
        description: String? = nil,
        iconName: String = "square.grid.2x2.fill",
        colorHex: String = "#2DD4BF",
        dreamImageName: String? = nil,
        persona: BabciaPersona = .classic,
        streamingCameraId: UUID? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.areaDescription = description
        self.iconName = iconName
        self.colorHex = colorHex
        self.createdAt = Date()
        self.dreamImageName = dreamImageName
        self.personaRaw = persona.rawValue
        self.streamingCameraId = streamingCameraId
        self.bowls = []
    }

    var color: Color {
        Color(hex: colorHex) ?? .teal
    }

    var persona: BabciaPersona {
        get { BabciaPersona(rawValue: personaRaw) ?? .classic }
        set { personaRaw = newValue.rawValue }
    }

    var latestDreamBowl: AreaBowl? {
        bowls?
            .sorted { $0.createdAt > $1.createdAt }
            .first { bowl in
                if let heroData = bowl.dreamHeroImageData {
                    return !heroData.isEmpty
                }
                return false
            }
    }

    var hasDreamVision: Bool {
        if let heroData = latestDreamBowl?.dreamHeroImageData, !heroData.isEmpty {
            return true
        }
        if let name = dreamImageName, !name.isEmpty {
            return true
        }
        return false
    }

    var ageInDays: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: createdAt)
        let end = calendar.startOfDay(for: Date())
        let dayCount = calendar.dateComponents([.day], from: start, to: end).day ?? 0
        return max(1, dayCount + 1)
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
    @Relationship(inverse: \AreaBowl.tasks) var bowl: AreaBowl?
    @Relationship(inverse: \Session.tasks) var session: Session?

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
