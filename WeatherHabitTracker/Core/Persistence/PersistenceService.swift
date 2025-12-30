// PersistenceService.swift
// WeatherHabitTracker

import Foundation
import SwiftData

@MainActor
final class PersistenceService {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Generic CRUD Operations
    
    func save() throws {
        try modelContext.save()
    }
    
    func insert<T: PersistentModel>(_ model: T) {
        modelContext.insert(model)
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        modelContext.delete(model)
    }
    
    /// Fetches all models of a specific type
    /// - Returns: Array of fetched models
    /// - Throws: Error if fetch fails
    func fetchAll<T: PersistentModel>() throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches models matching a predicate
    /// - Parameter predicate: The predicate to filter by
    /// - Returns: Array of matching models
    /// - Throws: Error if fetch fails
    func fetch<T: PersistentModel>(predicate: Predicate<T>) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Habit Operations
    
    /// Fetches all habits sorted by creation date
    /// - Returns: Array of habits
    /// - Throws: Error if fetch fails
    func fetchHabits() throws -> [Habit] {
        var descriptor = FetchDescriptor<Habit>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 100
        return try modelContext.fetch(descriptor)
    }
    
    /// Creates and saves a new habit
    /// - Parameter habit: The habit to create
    /// - Throws: Error if save fails
    func createHabit(_ habit: Habit) throws {
        modelContext.insert(habit)
        try modelContext.save()
    }
    
    /// Updates an existing habit
    /// - Parameter habit: The habit with updated values
    /// - Throws: Error if save fails
    func updateHabit(_ habit: Habit) throws {
        try modelContext.save()
    }
    
    /// Deletes a habit
    /// - Parameter habit: The habit to delete
    /// - Throws: Error if save fails
    func deleteHabit(_ habit: Habit) throws {
        modelContext.delete(habit)
        try modelContext.save()
    }
    
    /// Records a completion for a habit
    /// - Parameters:
    ///   - habit: The habit to mark as complete
    ///   - note: Optional note about the completion
    /// - Throws: Error if save fails
    func completeHabit(_ habit: Habit, note: String? = nil) throws {
        let completion = HabitCompletion(completedAt: Date(), note: note)
        completion.habit = habit
        
        if habit.completions == nil {
            habit.completions = []
        }
        habit.completions?.append(completion)
        
        try modelContext.save()
    }
    
    /// Removes the most recent completion for today
    /// - Parameter habit: The habit to uncomplete
    /// - Throws: Error if save fails
    func uncompleteHabitForToday(_ habit: Habit) throws {
        guard let completions = habit.completions else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find today's completions
        let todayCompletions = completions.filter {
            calendar.startOfDay(for: $0.completedAt) == today
        }
        
        // Remove the most recent one
        if let lastCompletion = todayCompletions.last {
            modelContext.delete(lastCompletion)
            habit.completions?.removeAll { $0.id == lastCompletion.id }
            try modelContext.save()
        }
    }
    
    // MARK: - Weather Operations
    
    /// Fetches cached weather data for a location
    /// - Parameters:
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    /// - Returns: Cached WeatherData if available and not expired
    /// - Throws: Error if fetch fails
    func fetchCachedWeather(latitude: Double, longitude: Double) throws -> WeatherData? {
        let tolerance = 0.01 // ~1km tolerance
        
        let predicate = #Predicate<WeatherData> { weather in
            weather.latitude > latitude - tolerance &&
            weather.latitude < latitude + tolerance &&
            weather.longitude > longitude - tolerance &&
            weather.longitude < longitude + tolerance
        }
        
        let descriptor = FetchDescriptor<WeatherData>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.fetchedAt, order: .reverse)]
        )
        
        let results = try modelContext.fetch(descriptor)
        
        // Return only if not expired
        if let cached = results.first, !cached.isExpired {
            return cached
        }
        
        return nil
    }
    
    /// Caches weather data, removing old entries
    /// - Parameter weather: The weather data to cache
    /// - Throws: Error if save fails
    func cacheWeather(_ weather: WeatherData) throws {
        // Remove old weather data for this location
        let tolerance = 0.01
        let targetLat = weather.latitude
        let targetLon = weather.longitude
        
        let predicate = #Predicate<WeatherData> { w in
            w.latitude > targetLat - tolerance &&
            w.latitude < targetLat + tolerance &&
            w.longitude > targetLon - tolerance &&
            w.longitude < targetLon + tolerance
        }
        
        let descriptor = FetchDescriptor<WeatherData>(predicate: predicate)
        let oldData = try modelContext.fetch(descriptor)
        
        for old in oldData {
            modelContext.delete(old)
        }
        
        modelContext.insert(weather)
        try modelContext.save()
    }
    
    /// Fetches cached forecast data for a location
    /// - Parameters:
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    /// - Returns: Array of cached forecasts
    /// - Throws: Error if fetch fails
    func fetchCachedForecast(latitude: Double, longitude: Double) throws -> [WeatherForecast] {
        let tolerance = 0.01
        let today = Calendar.current.startOfDay(for: Date())
        
        let predicate = #Predicate<WeatherForecast> { forecast in
            forecast.latitude > latitude - tolerance &&
            forecast.latitude < latitude + tolerance &&
            forecast.longitude > longitude - tolerance &&
            forecast.longitude < longitude + tolerance &&
            forecast.date >= today
        }
        
        let descriptor = FetchDescriptor<WeatherForecast>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Caches forecast data, removing old entries
    /// - Parameter forecasts: The forecast data to cache
    /// - Throws: Error if save fails
    func cacheForecast(_ forecasts: [WeatherForecast]) throws {
        guard let first = forecasts.first else { return }
        
        // Remove old forecast data for this location
        let tolerance = 0.01
        let latitude = first.latitude
        let longitude = first.longitude
        
        let predicate = #Predicate<WeatherForecast> { f in
            f.latitude > latitude - tolerance &&
            f.latitude < latitude + tolerance &&
            f.longitude > longitude - tolerance &&
            f.longitude < longitude + tolerance
        }
        
        let descriptor = FetchDescriptor<WeatherForecast>(predicate: predicate)
        let oldData = try modelContext.fetch(descriptor)
        
        for old in oldData {
            modelContext.delete(old)
        }
        
        for forecast in forecasts {
            modelContext.insert(forecast)
        }
        
        try modelContext.save()
    }
    
    // MARK: - Cleanup Operations
    
    /// Removes expired weather data
    /// - Throws: Error if operation fails
    func cleanupExpiredWeatherData() throws {
        let now = Date()
        
        // Clean up expired current weather
        let weatherPredicate = #Predicate<WeatherData> { weather in
            weather.expiresAt < now
        }
        let weatherDescriptor = FetchDescriptor<WeatherData>(predicate: weatherPredicate)
        let expiredWeather = try modelContext.fetch(weatherDescriptor)
        
        for weather in expiredWeather {
            modelContext.delete(weather)
        }
        
        // Clean up old forecasts
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let forecastPredicate = #Predicate<WeatherForecast> { forecast in
            forecast.date < yesterday
        }
        let forecastDescriptor = FetchDescriptor<WeatherForecast>(predicate: forecastPredicate)
        let oldForecasts = try modelContext.fetch(forecastDescriptor)
        
        for forecast in oldForecasts {
            modelContext.delete(forecast)
        }
        
        try modelContext.save()
    }
}
