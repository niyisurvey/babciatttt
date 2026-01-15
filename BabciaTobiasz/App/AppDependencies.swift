//
//  AppDependencies.swift
//  BabciaTobiasz
//

import Foundation
import SwiftUI

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
    
    // MARK: - Init
    
    init(
        weatherService: WeatherService? = nil,
        notificationService: NotificationService? = nil,
        locationService: LocationService? = nil,
        dreamPipelineService: DreamPipelineService? = nil,
        // Added 2026-01-14 22:55 GMT
        scanPipelineService: BabciaScanPipelineService? = nil
    ) {
        let location = locationService ?? LocationService()
        self.locationService = location
        self.weatherService = weatherService ?? WeatherService(locationService: location)
        self.notificationService = notificationService ?? NotificationService()
        self.dreamPipelineService = dreamPipelineService ?? DreamPipelineService()
        self.scanPipelineService = scanPipelineService ?? BabciaScanPipelineService()
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
