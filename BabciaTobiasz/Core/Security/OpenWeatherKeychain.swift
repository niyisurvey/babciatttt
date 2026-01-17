//
//  OpenWeatherKeychain.swift
//  BabciaTobiasz
//
//  Stores the OpenWeather API key securely in the Keychain.
//

import Foundation

enum OpenWeatherKeychain {
    private static let service = "com.babcia.tobiasz"
    private static let account = "OPENWEATHERMAP_API_KEY"

    static func load() -> String? {
        KeychainService.get(service: service, account: account)
    }

    @discardableResult
    static func save(_ value: String) -> Bool {
        KeychainService.set(value, service: service, account: account)
    }

    @discardableResult
    static func delete() -> Bool {
        KeychainService.delete(service: service, account: account)
    }
}
