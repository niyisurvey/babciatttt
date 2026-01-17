// NotificationService.swift
// BabciaTobiasz

import Foundation
import UserNotifications
import os

@MainActor
@Observable
final class NotificationService {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "com.babcia.tobiasz", category: "notifications")
    
    private var notificationCenter: UNUserNotificationCenter? {
        guard Bundle.main.bundleIdentifier != nil else { return nil }
        return UNUserNotificationCenter.current()
    }
    
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    var isAuthorized: Bool { authorizationStatus == .authorized }
    
    // MARK: - Initialization
    
    init() {
        Task { await checkAuthorizationStatus() }
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() async {
        guard let center = notificationCenter else { return }
        let settings = await center.notificationSettings()
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
        }
    }
    
    /// Requests notification authorization from the user
    /// - Returns: Whether authorization was granted
    @discardableResult
    func requestAuthorization() async -> Bool {
        guard let center = notificationCenter else {
            logger.warning("Notification authorization skipped: missing bundle identifier.")
            return false
        }

        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await MainActor.run {
                self.authorizationStatus = granted ? .authorized : .denied
            }
            return granted
        } catch {
            logger.error("Notification authorization failed: \(error.localizedDescription, privacy: .public)")
            return false
        }
    }
    
    // MARK: - Scheduling
    
    /// Schedules a daily reminder notification for an area
    /// - Parameters:
    ///   - areaName: The area name to display
    ///   - areaDescription: Optional description for the reminder body
    ///   - reminderTime: The time of day to remind
    ///   - areaId: The area identifier for tracking
    /// - Throws: NotificationError if scheduling fails
    func scheduleAreaReminder(
        areaName: String,
        areaDescription: String?,
        reminderTime: Date,
        areaId: UUID
    ) async throws {
        
        // Ensure we have authorization
        var authorized = isAuthorized
        if !authorized {
            authorized = await requestAuthorization()
        }
        
        guard authorized else {
            throw NotificationError.notAuthorized
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Time for \(areaName)"
        content.body = areaDescription ?? "Don't forget to complete your bowl!"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "AREA_REMINDER"
        content.userInfo = ["areaId": areaId.uuidString]
        
        // Create daily trigger based on reminder time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create request with area ID as identifier
        let identifier = "area-\(areaId.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule the notification
        if let center = notificationCenter {
            try await center.add(request)
        }
    }
    
    /// Cancels notification for a specific area
    /// - Parameter areaId: The area to cancel notifications for
    func cancelAreaReminder(for areaId: UUID) {
        let identifier = "area-\(areaId.uuidString)"
        notificationCenter?.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Updates notification for an area (cancels existing and schedules new)
    func updateAreaReminder(
        areaName: String,
        areaDescription: String?,
        reminderTime: Date,
        areaId: UUID
    ) async throws {
        cancelAreaReminder(for: areaId)
        try await scheduleAreaReminder(
            areaName: areaName,
            areaDescription: areaDescription,
            reminderTime: reminderTime,
            areaId: areaId
        )
    }
    
    /// Cancels all pending area notifications
    func cancelAllAreaReminders() {
        notificationCenter?.removeAllPendingNotificationRequests()
    }
    
    /// Gets all pending notification requests
    /// - Returns: Array of pending notification requests
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await notificationCenter?.pendingNotificationRequests() ?? []
    }
    
    // MARK: - Badge Management
    
    /// Clears the app badge
    @MainActor
    func clearBadge() {
        notificationCenter?.setBadgeCount(0)
    }
    
    /// Sets the app badge to a specific count
    /// - Parameter count: The badge count to set
    @MainActor
    func setBadge(count: Int) {
        notificationCenter?.setBadgeCount(count)
    }
    
    // MARK: - Notification Categories
    
    /// Registers notification categories and actions
    func registerNotificationCategories() {
        // Action to mark bowl as complete from notification
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_BOWL",
            title: "Mark Complete",
            options: [.foreground]
        )
        
        // Action to snooze the reminder
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_BOWL",
            title: "Remind in 1 hour",
            options: []
        )
        
        // Define the area reminder category
        let areaCategory = UNNotificationCategory(
            identifier: "AREA_REMINDER",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        notificationCenter?.setNotificationCategories([areaCategory])
    }
}

// MARK: - NotificationError

/// Errors that can occur when managing notifications
enum NotificationError: LocalizedError {
    case notAuthorized
    case schedulingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Notification permission not granted. Please enable notifications in Settings."
        case .schedulingFailed(let error):
            return "Failed to schedule notification: \(error.localizedDescription)"
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate Support

/// Extension to help with notification handling
extension NotificationService {
    /// Handles a notification action
    /// - Parameters:
    ///   - actionIdentifier: The action that was selected
    ///   - areaId: The area ID from the notification
    /// - Returns: The action type that was performed
    func handleNotificationAction(
        actionIdentifier: String,
        areaId: String
    ) -> NotificationAction {
        switch actionIdentifier {
        case "COMPLETE_BOWL":
            return .complete(areaId: areaId)
        case "SNOOZE_BOWL":
            return .snooze(areaId: areaId)
        case UNNotificationDismissActionIdentifier:
            return .dismiss
        default:
            return .open(areaId: areaId)
        }
    }
}

/// Actions that can be performed from a notification
enum NotificationAction {
    case complete(areaId: String)
    case snooze(areaId: String)
    case dismiss
    case open(areaId: String)
}
