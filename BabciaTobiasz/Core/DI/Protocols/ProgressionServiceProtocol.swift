//
//  ProgressionServiceProtocol.swift
//  BabciaTobiasz
//

import Foundation

@MainActor
protocol ProgressionServiceProtocol {
    func getMilestone(for area: Area) -> MilestoneDisplay?
    func awardBonus(for area: Area) async
}
