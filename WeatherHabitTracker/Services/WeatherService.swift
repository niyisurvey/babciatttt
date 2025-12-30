//
//  WeatherService.swift
//  WeatherHabitTracker
//
//  Service responsible for fetching weather data.
//  Uses OpenWeatherMap API with async/await for modern Swift concurrency.
//

import Foundation
import CoreLocation

/// Service that handles weather data fetching from OpenWeatherMap API.
/// Supports both current weather and 7-day forecast.
/// Designed for async/await usage with proper error handling.
actor WeatherService {
    
    // MARK: - Configuration
    
    /// OpenWeatherMap API configuration
    /// API key is loaded from Secrets.plist for security
    private struct Config {
        static let apiKey: String = {
            // Try to find Secrets.plist in the SwiftPM resource bundle, then fall back to the main bundle
            let secretsURL = Bundle.module.url(forResource: "Secrets", withExtension: "plist")
                ?? Bundle.main.url(forResource: "Secrets", withExtension: "plist")
            guard let url = secretsURL else {
                print("⚠️ Warning: Secrets.plist not found in any bundle")
                return ""
            }
            do {
                let data = try Data(contentsOf: url)
                guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                    print("⚠️ Warning: Secrets.plist at \(url) is not a valid property list")
                    return ""
                }
                let rawKey = (plist["OPENWEATHERMAP_API_KEY"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                guard !rawKey.isEmpty else {
                    print("⚠️ Warning: OPENWEATHERMAP_API_KEY is missing or empty in Secrets.plist at \(url)")
                    return ""
                }
                return rawKey
            } catch {
                print("⚠️ Warning: Failed to read Secrets.plist at \(url): \(error.localizedDescription)")
                return ""
            }
        }()
        static let baseURL = "https://api.openweathermap.org/data/2.5"
        static let oneCallURL = "https://api.openweathermap.org/data/3.0/onecall"
        static let units = "metric" // Use Celsius
    }
    
    // MARK: - Properties
    
    /// Location service for getting user location
    private let locationService: LocationService
    
    /// URL session for network requests
    private let session: URLSession
    
    /// JSON decoder configured for weather API responses
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    /// Creates a new WeatherService instance
    /// - Parameter locationService: The location service to use for coordinates
    init(locationService: LocationService) {
        self.locationService = locationService
        
        // Configure URL session with timeout
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        // Configure JSON decoder
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    // MARK: - Public Methods
    
    /// Fetches current weather for the user's location
    /// - Returns: WeatherResponseDTO with current conditions
    /// - Throws: WeatherError if the request fails
    func fetchCurrentWeather() async throws -> WeatherResponseDTO {
        let location: CLLocation
        do {
            location = try await locationService.requestLocation()
        } catch {
            print("Location request failed: \(error.localizedDescription). Using default location (San Francisco).")
            location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        }
        
        return try await fetchCurrentWeather(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    /// Fetches current weather for specific coordinates
    /// - Parameters:
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    /// - Returns: WeatherResponseDTO with current conditions
    /// - Throws: WeatherError if the request fails
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherResponseDTO {
        // Build URL
        var components = URLComponents(string: "\(Config.baseURL)/weather")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: Config.units),
            URLQueryItem(name: "appid", value: Config.apiKey)
        ]
        
        guard let url = components.url else {
            throw WeatherError.invalidURL
        }
        
        // Fetch data
        let (data, response) = try await session.data(from: url)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Parse response
        return try decoder.decode(WeatherResponseDTO.self, from: data)
    }
    
    /// Fetches 7-day forecast for the user's location
    /// - Returns: ForecastResponseDTO
    /// - Throws: WeatherError if the request fails
    func fetchForecast() async throws -> ForecastResponseDTO {
        let location: CLLocation
        do {
            location = try await locationService.requestLocation()
        } catch {
            print("Location request failed: \(error.localizedDescription). Using default location (San Francisco).")
            location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        }
        
        return try await fetchForecast(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    /// Fetches 7-day forecast for specific coordinates
    /// - Parameters:
    ///   - latitude: Latitude coordinate
    ///   - longitude: Longitude coordinate
    /// - Returns: ForecastResponseDTO
    /// - Throws: WeatherError if the request fails
    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastResponseDTO {
        // Build URL for 5-day/3-hour forecast (free tier)
        var components = URLComponents(string: "\(Config.baseURL)/forecast")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: Config.units),
            URLQueryItem(name: "appid", value: Config.apiKey)
        ]
        
        guard let url = components.url else {
            throw WeatherError.invalidURL
        }
        
        // Fetch data
        let (data, response) = try await session.data(from: url)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // Parse response
        return try decoder.decode(ForecastResponseDTO.self, from: data)
    }
}



// MARK: - WeatherError

/// Errors that can occur when fetching weather data
enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noData
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid weather API URL."
        case .invalidResponse:
            return "Invalid response from weather service."
        case .httpError(let statusCode):
            if statusCode == 401 {
                return "Invalid API key. Please check your OpenWeatherMap API key."
            }
            return "Weather service error (HTTP \(statusCode))."
        case .decodingError(let error):
            return "Failed to parse weather data: \(error.localizedDescription)"
        case .noData:
            return "No weather data available."
        case .apiKeyMissing:
            return "OpenWeatherMap API key is not configured."
        }
    }
}
