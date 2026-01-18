//
//  ReminderSchedulerProtocol.swift
//  BabciaTobiasz
//

import Foundation

protocol ReminderSchedulerProtocol: Sendable {
    func schedule(for areaId: UUID, config: ReminderConfigSnapshot) async throws
    func cancelAll(for areaId: UUID)
}
