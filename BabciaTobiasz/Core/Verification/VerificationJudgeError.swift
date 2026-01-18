//
//  VerificationJudgeError.swift
//  BabciaTobiasz
//
//  Error types for verification judging.
//

import Foundation

/// Errors that can occur during verification judging.
enum VerificationJudgeError: Error, LocalizedError, @unchecked Sendable {
    case apiKeyMissing
    case invalidPhotoData
    case networkFailure(underlying: Error)
    case invalidResponse(reason: String)
    case judgingFailed(reason: String)

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return String(localized: "verification.error.apiKeyMissing")
        case .invalidPhotoData:
            return String(localized: "verification.error.invalidPhotoData")
        case .networkFailure(let error):
            return String(
                format: String(localized: "verification.error.networkFailure"),
                error.localizedDescription
            )
        case .invalidResponse(let reason):
            return String(
                format: String(localized: "verification.error.invalidResponse"),
                reason
            )
        case .judgingFailed(let reason):
            return String(
                format: String(localized: "verification.error.judgingFailed"),
                reason
            )
        }
    }
}
