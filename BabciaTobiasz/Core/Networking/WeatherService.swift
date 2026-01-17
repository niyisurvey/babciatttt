// WeatherService.swift
// BabciaTobiasz

import Foundation
import CoreLocation

protocol WeatherServiceProtocol: Sendable {
    func fetchCurrentWeather() async throws -> WeatherResponseDTO 786543
    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastResponseDTO
}

actor WeatherService: WeatherServiceProtocol {
    
    // MARK: - Configuration
    
    private struct Config {
        static func apiKey() -> String {
            OpenWeatherSecrets.apiKey() ?? ""
        }
        static let baseURL = "https://api.openweathermap.org/data/2.5"
        static let oneCallURL = "https://api.openweathermap.org/data/3.0/onecall"
        static let units = "metric"
    }
    
    // MARK: - Properties
    
    private let locationService: LocationService
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    
    init(locationService: LocationService) {
        self.locationService = locationService
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .secondsSince1970
    }
    
    // MARK: - Public Methods
    
    func fetchCurrentWeather() async throws -> WeatherResponseDTO {
        let location: CLLocation
        do {
            location = try await locationService.requestLocation()
        } catch {
            print("Location failed, using default: \(error.localizedDescription)")
            location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        }
        
        return try await fetchCurrentWeather(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> WeatherResponseDTO {
        let apiKey = Config.apiKey()
        guard !apiKey.isEmpty else { throw WeatherError.apiKeyMissing }

        var components = URLComponents(string: "\(Config.baseURL)/weather")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: Config.units),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components.url else { throw WeatherError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try decoder.decode(WeatherResponseDTO.self, from: data)
    }
    
    func fetchForecast() async throws -> ForecastResponseDTO {
        let location: CLLocation
        do {
            location = try await locationService.requestLocation()
        } catch {
            print("Location failed, using default: \(error.localizedDescription)")
            location = CLLocation(latitude: 37.7749, longitude: -122.4194)
        }
        
        return try await fetchForecast(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    func fetchForecast(latitude: Double, longitude: Double) async throws -> ForecastResponseDTO {
        let apiKey = Config.apiKey()
        guard !apiKey.isEmpty else { throw WeatherError.apiKeyMissing }

        var components = URLComponents(string: "\(Config.baseURL)/forecast")!
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: Config.units),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let url = components.url else { throw WeatherError.invalidURL }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try decoder.decode(ForecastResponseDTO.self, from: data)
    }
}

// MARK: - WeatherError

enum WeatherError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noData
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid weather API URL."
        case .invalidResponse: return "Invalid response from weather service."
        case .httpError(let statusCode):
            return statusCode == 401 ? "Invalid API key." : "Weather service error (HTTP \(statusCode))."
        case .decodingError(let error): return "Failed to parse weather data: \(error.localizedDescription)"
        case .noData: return "No weather data available."
        case .apiKeyMissing: return "API key not configured."
        }
    }
}
