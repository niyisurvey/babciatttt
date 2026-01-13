// PersistenceService.swift
// BabciaTobiasz

import Foundation
import SwiftData

@MainActor
final class PersistenceService {
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD
    
    func save() throws {
        try modelContext.save()
    }
    
    func insert<T: PersistentModel>(_ model: T) {
        modelContext.insert(model)
    }
    
    func delete<T: PersistentModel>(_ model: T) {
        modelContext.delete(model)
    }
    
    func fetchAll<T: PersistentModel>() throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try modelContext.fetch(descriptor)
    }
    
    func fetch<T: PersistentModel>(predicate: Predicate<T>) throws -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Areas
    
    func fetchAreas() throws -> [Area] {
        var descriptor = FetchDescriptor<Area>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 200
        return try modelContext.fetch(descriptor)
    }
    
    func createArea(_ area: Area) throws {
        modelContext.insert(area)
        try modelContext.save()
    }
    
    func updateArea(_ area: Area) throws {
        try modelContext.save()
    }
    
    func deleteArea(_ area: Area) throws {
        modelContext.delete(area)
        try modelContext.save()
    }
    
    func createBowl(for area: Area, tasks: [CleaningTask], verificationRequested: Bool) throws -> AreaBowl {
        let bowl = AreaBowl(createdAt: Date(), verificationRequested: verificationRequested)
        bowl.area = area
        bowl.tasks = tasks
        area.bowls?.append(bowl)
        modelContext.insert(bowl)
        try modelContext.save()
        return bowl
    }
    
    func completeTask(_ task: CleaningTask) throws {
        task.completedAt = Date()
        try modelContext.save()
    }
    
    func uncompleteTask(_ task: CleaningTask) throws {
        task.completedAt = nil
        try modelContext.save()
    }
    
    func verifyBowl(_ bowl: AreaBowl, tier: BowlVerificationTier, outcome: BowlVerificationOutcome) throws {
        bowl.verificationTier = tier
        bowl.verificationOutcome = outcome
        bowl.verifiedAt = Date()
        try modelContext.save()
    }
    
    // MARK: - Weather
    
    func fetchCachedWeather(latitude: Double, longitude: Double) throws -> WeatherData? {
        let tolerance = 0.01
        
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
        
        if let cached = results.first, !cached.isExpired {
            return cached
        }
        
        return nil
    }
    
    func cacheWeather(_ weather: WeatherData) throws {
        let tolerance = 0.01
        let targetLat = weather.latitude
        let targetLon = weather.longitude
        
        let predicate = #Predicate<WeatherData> { weather in
            weather.latitude > targetLat - tolerance &&
            weather.latitude < targetLat + tolerance &&
            weather.longitude > targetLon - tolerance &&
            weather.longitude < targetLon + tolerance
        }
        
        let descriptor = FetchDescriptor<WeatherData>(predicate: predicate)
        let oldData = try modelContext.fetch(descriptor)
        
        for old in oldData {
            modelContext.delete(old)
        }
        
        modelContext.insert(weather)
        try modelContext.save()
    }
    
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
    
    func cacheForecast(_ forecasts: [WeatherForecast]) throws {
        guard let first = forecasts.first else { return }
        
        let tolerance = 0.01
        let latitude = first.latitude
        let longitude = first.longitude
        
        let predicate = #Predicate<WeatherForecast> { forecast in
            forecast.latitude > latitude - tolerance &&
            forecast.latitude < latitude + tolerance &&
            forecast.longitude > longitude - tolerance &&
            forecast.longitude < longitude + tolerance
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
