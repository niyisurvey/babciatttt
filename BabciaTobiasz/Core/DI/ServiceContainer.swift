//
//  ServiceContainer.swift
//  BabciaTobiasz
//

import Foundation

@MainActor
final class ServiceContainer {
    let progression: any ProgressionServiceProtocol
    let reminders: any ReminderSchedulerProtocol

    init(
        progression: any ProgressionServiceProtocol,
        reminders: any ReminderSchedulerProtocol
    ) {
        self.progression = progression
        self.reminders = reminders
    }
}
