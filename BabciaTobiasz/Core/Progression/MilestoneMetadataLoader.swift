//
//  MilestoneMetadataLoader.swift
//  BabciaTobiasz
//

import Foundation

struct MilestoneMetadata: Codable, Identifiable, Hashable {
    let persona: String
    let day: Int
    let badgeSystemName: String?
    let bonusPoints: Int?
    let copyKey: String

    var id: String { "\(persona)-day-\(day)" }

    static var defaults: [MilestoneMetadata] {
        [
            MilestoneMetadata(persona: "classic", day: 1, badgeSystemName: "sparkles", bonusPoints: 5, copyKey: "milestone.classic.day1"),
            MilestoneMetadata(persona: "classic", day: 3, badgeSystemName: "leaf.fill", bonusPoints: 8, copyKey: "milestone.classic.day3"),
            MilestoneMetadata(persona: "classic", day: 5, badgeSystemName: "cup.and.saucer.fill", bonusPoints: 10, copyKey: "milestone.classic.day5"),
            MilestoneMetadata(persona: "classic", day: 7, badgeSystemName: "tshirt.fill", bonusPoints: 12, copyKey: "milestone.classic.day7"),
            MilestoneMetadata(persona: "classic", day: 14, badgeSystemName: "heart.fill", bonusPoints: 20, copyKey: "milestone.classic.day14"),
            MilestoneMetadata(persona: "classic", day: 30, badgeSystemName: "star.fill", bonusPoints: 30, copyKey: "milestone.classic.day30"),
            MilestoneMetadata(persona: "baroness", day: 1, badgeSystemName: "crown.fill", bonusPoints: 5, copyKey: "milestone.baroness.day1"),
            MilestoneMetadata(persona: "baroness", day: 7, badgeSystemName: "crown", bonusPoints: 12, copyKey: "milestone.baroness.day7"),
            MilestoneMetadata(persona: "baroness", day: 30, badgeSystemName: "seal.fill", bonusPoints: 30, copyKey: "milestone.baroness.day30"),
            MilestoneMetadata(persona: "warrior", day: 1, badgeSystemName: "flame.fill", bonusPoints: 5, copyKey: "milestone.warrior.day1"),
            MilestoneMetadata(persona: "warrior", day: 7, badgeSystemName: "shield.fill", bonusPoints: 12, copyKey: "milestone.warrior.day7"),
            MilestoneMetadata(persona: "warrior", day: 30, badgeSystemName: "flag.checkered", bonusPoints: 30, copyKey: "milestone.warrior.day30"),
            MilestoneMetadata(persona: "wellness", day: 1, badgeSystemName: "waveform.path.ecg", bonusPoints: 5, copyKey: "milestone.wellness.day1"),
            MilestoneMetadata(persona: "wellness", day: 7, badgeSystemName: "sparkles", bonusPoints: 12, copyKey: "milestone.wellness.day7"),
            MilestoneMetadata(persona: "wellness", day: 30, badgeSystemName: "circle.grid.cross.fill", bonusPoints: 30, copyKey: "milestone.wellness.day30"),
            MilestoneMetadata(persona: "coach", day: 1, badgeSystemName: "bolt.fill", bonusPoints: 5, copyKey: "milestone.coach.day1"),
            MilestoneMetadata(persona: "coach", day: 7, badgeSystemName: "bolt.circle.fill", bonusPoints: 12, copyKey: "milestone.coach.day7"),
            MilestoneMetadata(persona: "coach", day: 30, badgeSystemName: "trophy.fill", bonusPoints: 30, copyKey: "milestone.coach.day30")
        ]
    }
}

struct MilestoneMetadataLoader {
    func load() -> [MilestoneMetadata] {
        guard let url = Bundle.main.url(forResource: "MilestoneMetadata", withExtension: "json") else {
            return MilestoneMetadata.defaults
        }
        guard let data = try? Data(contentsOf: url) else {
            return MilestoneMetadata.defaults
        }
        guard let decoded = try? JSONDecoder().decode([MilestoneMetadata].self, from: data) else {
            return MilestoneMetadata.defaults
        }
        return decoded
    }
}
