//
//  WeatherDTOs.swift
//  WeatherHabitTracker
//
//  Data Transfer Objects for OpenWeatherMap API responses.
//  Decouples the network layer from the SwiftData models.
//

import Foundation

// MARK: - Current Weather Response

struct WeatherResponseDTO: Codable, Sendable {
    let coord: CoordDTO
    let weather: [WeatherConditionDTO]
    let main: MainWeatherDTO
    let wind: WindDTO
    let dt: TimeInterval
    let sys: SysDTO
    let name: String
}

struct CoordDTO: Codable, Sendable {
    let lon: Double
    let lat: Double
}

struct WeatherConditionDTO: Codable, Sendable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct MainWeatherDTO: Codable, Sendable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
}

struct WindDTO: Codable, Sendable {
    let speed: Double
    let deg: Int
}

struct SysDTO: Codable, Sendable {
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

// MARK: - Forecast Response

struct ForecastResponseDTO: Codable, Sendable {
    let list: [ForecastItemDTO]
    let city: CityDTO
}

struct ForecastItemDTO: Codable, Sendable {
    let dt: TimeInterval
    let main: MainWeatherDTO
    let weather: [WeatherConditionDTO]
    let wind: WindDTO
    let pop: Double
}

struct CityDTO: Codable, Sendable {
    let name: String
    let coord: CoordDTO
    let sunrise: TimeInterval
    let sunset: TimeInterval
}
