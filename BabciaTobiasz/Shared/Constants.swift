//
//  Constants.swift
//  BabciaTobiasz
//
//  App-wide constants and configuration values.
//

import Foundation

/// App-wide constants namespace
enum Constants {
    
    // MARK: - App Info
    
    enum App {
        static let name = "BabciaTobiasz"
        static let bundleIdentifier = "com.babcia.tobiasz"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - API Configuration
    
    enum API {
        static let weatherBaseURL = "https://api.openweathermap.org/data/2.5"
        static let weatherOneCallURL = "https://api.openweathermap.org/data/3.0/onecall"
        static let requestTimeout: TimeInterval = 30
        static let resourceTimeout: TimeInterval = 60
    }
    
    // MARK: - Cache Settings
    
    enum Cache {
        /// Weather data cache duration in seconds (15 minutes)
        static let weatherDataDuration: TimeInterval = 15 * 60
        
        /// Forecast cache duration in seconds (1 hour)
        static let forecastDuration: TimeInterval = 60 * 60
    }
    
    // MARK: - UI Constants
    
    enum UI {
        /// Standard corner radius for cards
        static let cardCornerRadius: CGFloat = 20
        
        /// Standard padding
        static let standardPadding: CGFloat = 16
        
        /// Icon sizes
        static let smallIconSize: CGFloat = 24
        static let mediumIconSize: CGFloat = 44
        static let largeIconSize: CGFloat = 80
        
        /// Animation durations
        static let shortAnimation: Double = 0.2
        static let standardAnimation: Double = 0.3
        static let longAnimation: Double = 0.5
    }
    
    // MARK: - Area Defaults
    
    enum Areas {
        /// Maximum area name length
        static let maxNameLength = 50
        
        /// Maximum description length
        static let maxDescriptionLength = 200
    }
    
    // MARK: - Notifications
    
    enum Notifications {
        /// Notification category identifiers
        static let areaReminderCategory = "AREA_REMINDER"
        static let weatherAlertCategory = "WEATHER_ALERT"
        
        /// Action identifiers
        static let completeBowlAction = "COMPLETE_BOWL"
        static let snoozeAction = "SNOOZE_BOWL"
    }
}
