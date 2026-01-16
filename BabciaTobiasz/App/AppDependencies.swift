//
//  AppDependencies.swift
//  BabciaTobiasz
//

import Foundation
import SwiftUI
import UserNotifications

/// Dependency injection container for app services
@Observable @MainActor
final class AppDependencies {
    
    // MARK: - Services
    
    let weatherService: WeatherService
    let notificationService: NotificationService
    let locationService: LocationService
    let dreamPipelineService: DreamPipelineService
    // Added 2026-01-14 22:55 GMT
    let scanPipelineService: BabciaScanPipelineService
    let services: ServiceContainer
    let reminderNotificationRouter: ReminderNotificationRouter
    
    // MARK: - Init
    
    init(
        weatherService: WeatherService? = nil,
        notificationService: NotificationService? = nil,
        locationService: LocationService? = nil,
        dreamPipelineService: DreamPipelineService? = nil,
        // Added 2026-01-14 22:55 GMT
        scanPipelineService: BabciaScanPipelineService? = nil,
        reminderScheduler: ReminderSchedulerProtocol? = nil,
        progressionService: ProgressionServiceProtocol? = nil,
        reminderNotificationRouter: ReminderNotificationRouter? = nil
    ) {
        let location = locationService ?? LocationService()
        self.locationService = location
        self.weatherService = weatherService ?? WeatherService(locationService: location)
        self.notificationService = notificationService ?? NotificationService()
        self.dreamPipelineService = dreamPipelineService ?? DreamPipelineService()
        self.scanPipelineService = scanPipelineService ?? BabciaScanPipelineService()
        let progression = progressionService ?? ProgressionService()
        let reminders = reminderScheduler ?? ReminderScheduler()
        self.services = ServiceContainer(progression: progression, reminders: reminders)
        self.reminderNotificationRouter = reminderNotificationRouter ?? ReminderNotificationRouter()
        UNUserNotificationCenter.current().delegate = self.reminderNotificationRouter
        self.reminderNotificationRouter.registerNotificationCategories()
    }
}

// MARK: - Environment Key

private struct AppDependenciesKey: @preconcurrency EnvironmentKey {
    @MainActor static let defaultValue = AppDependencies()
}

extension EnvironmentValues {
    var appDependencies: AppDependencies {
        get { self[AppDependenciesKey.self] }
        set { self[AppDependenciesKey.self] = newValue }
    }
}
