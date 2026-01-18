//
//  ReminderNotificationRouter.swift
//  BabciaTobiasz
//

import Foundation
import UserNotifications

extension Notification.Name {
    static let areaReminderTapped = Notification.Name("areaReminderTapped")
}

final class ReminderNotificationRouter: NSObject, UNUserNotificationCenterDelegate {
    func registerNotificationCategories() {
        let openAction = UNNotificationAction(
            identifier: Constants.Notifications.openAreaAction,
            title: String(localized: "reminders.action.open"),
            options: [.foreground]
        )

        let category = UNNotificationCategory(
            identifier: Constants.Notifications.areaReminderCategory,
            actions: [openAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }
        let userInfo = response.notification.request.content.userInfo
        guard let areaIdString = userInfo["areaId"] as? String,
              let areaId = UUID(uuidString: areaIdString) else {
            return
        }
        NotificationCenter.default.post(
            name: .areaReminderTapped,
            object: nil,
            userInfo: ["areaId": areaId]
        )
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
