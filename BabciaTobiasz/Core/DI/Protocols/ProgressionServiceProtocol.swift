//
//  ProgressionServiceProtocol.swift
//  BabciaTobiasz
//

import Foundation

protocol ProgressionServiceProtocol: Sendable {
    func getMilestone(for area: Area) -> MilestoneDisplay?
    func awardBonus(for area: Area) async
}
