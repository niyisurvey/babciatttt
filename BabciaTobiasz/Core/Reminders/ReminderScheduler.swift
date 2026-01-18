//
//  ReminderScheduler.swift
//  BabciaTobiasz
//

import Foundation
import UserNotifications

enum ReminderError: LocalizedError {
    case permissionDenied
    case schedulingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return String(localized: "reminders.error.permissionDenied")
        case .schedulingFailed(let error):
            return String(format: String(localized: "reminders.error.scheduleFailed"), error.localizedDescription)
        }
    }
}

struct ReminderScheduler: ReminderSchedulerProtocol {
    private var center: UNUserNotificationCenter {
        UNUserNotificationCenter.current()
    }

    func schedule(for areaId: UUID, config: ReminderConfigSnapshot) async throws {
        guard config.isEnabled else {
            cancelAll(for: areaId)
            return
        }

        let authorized = await ensureAuthorization()
        guard authorized else {
            throw ReminderError.permissionDenied
        }

        cancelAll(for: areaId)

        let times = config.slotTimes
        for index in 0..<times.count {
            guard let time = times[index] else { continue }
            let components = Calendar.current.dateComponents([.hour, .minute], from: time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            let content = UNMutableNotificationContent()
            let title = config.areaName ?? NSLocalizedString("app_name", comment: "Reminder default title")
            let body = config.areaDescription ?? NSLocalizedString("reminder_default_body", comment: "Reminder default body")
            content.title = title
            content.body = body
            content.sound = .default
            content.badge = 1
            content.categoryIdentifier = Constants.Notifications.areaReminderCategory
            content.userInfo = ["areaId": areaId.uuidString]

            let identifier = "area-\(areaId.uuidString)-slot-\(index)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            do {
                try await center.add(request)
            } catch {
                throw ReminderError.schedulingFailed(error)
            }
        }
    }

    func cancelAll(for areaId: UUID) {
        let identifiers = (0..<ReminderConfig.maxSlots).map { "area-\(areaId.uuidString)-slot-\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func ensureAuthorization() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            do {
                return try await center.requestAuthorization(options: [.alert, .sound, .badge])
            } catch {
                return false
            }
        default:
            return false
        }
    }
}
