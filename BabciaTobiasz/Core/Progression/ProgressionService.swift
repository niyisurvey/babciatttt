//
//  ProgressionService.swift
//  BabciaTobiasz
//

import Foundation

struct MilestoneDisplay: Identifiable, Hashable {
    let persona: BabciaPersona
    let day: Int
    let badgeSystemName: String?
    let bonusPoints: Int
    let copyKey: String

    var id: String { "\(persona.rawValue)-day-\(day)" }

    var localizedCopy: String {
        NSLocalizedString(copyKey, comment: "")
    }
}

@MainActor
final class ProgressionService: ProgressionServiceProtocol {
    typealias AwardHandler = @Sendable (Int) throws -> Void

    private let metadata: [MilestoneMetadata]
    private let userDefaults: UserDefaults
    private var awardHandler: AwardHandler?

    init(
        metadataLoader: MilestoneMetadataLoader = MilestoneMetadataLoader(),
        userDefaults: UserDefaults = .standard
    ) {
        self.metadata = metadataLoader.load()
        self.userDefaults = userDefaults
    }

    func configureAwardHandler(_ handler: AwardHandler?) {
        self.awardHandler = handler
    }

    func getMilestone(for area: Area) -> MilestoneDisplay? {
        let personaRaw = area.persona.rawValue
        let milestones = metadata
            .filter { $0.persona == personaRaw }
            .sorted { $0.day < $1.day }

        guard let milestone = milestones.last(where: { $0.day <= area.ageInDays }) else {
            return nil
        }

        return MilestoneDisplay(
            persona: area.persona,
            day: milestone.day,
            badgeSystemName: milestone.badgeSystemName,
            bonusPoints: milestone.bonusPoints ?? 0,
            copyKey: milestone.copyKey
        )
    }

    func awardBonus(for area: Area) async {
        guard let milestone = getMilestone(for: area) else { return }
        guard milestone.bonusPoints > 0 else { return }
        let areaKey = awardKey(for: area.id)
        var awardedDays = (userDefaults.array(forKey: areaKey) as? [Int]) ?? []
        guard !awardedDays.contains(milestone.day) else { return }

        do {
            if let awardHandler {
                try awardHandler(milestone.bonusPoints)
            }
            awardedDays.append(milestone.day)
            userDefaults.set(awardedDays, forKey: areaKey)
        } catch {
            // Silently ignore award failures to avoid blocking UI.
        }
    }

    private func awardKey(for areaId: UUID) -> String {
        "milestone_awarded_\(areaId.uuidString)"
    }
}
