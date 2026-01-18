//
//  FriendlyError.swift
//  BabciaTobiasz
//

import Foundation

enum FriendlyErrorAction: Equatable {
    case retry
    case openSettings
    case manageCameras

    var localizedTitle: String {
        switch self {
        case .retry:
            return String(localized: "error.action.retry")
        case .openSettings:
            return String(localized: "error.action.settings")
        case .manageCameras:
            return String(localized: "error.action.cameras")
        }
    }
}

struct FriendlyError: Equatable {
    let message: String
    let action: FriendlyErrorAction?
}

enum FriendlyErrorMapper {
    static func map(_ error: Error) -> FriendlyError {
        if let error = error as? DreamPipelineError {
            switch error {
            case .missingAPIKey:
                return FriendlyError(
                    message: error.localizedDescription,
                    action: .openSettings
                )
            default:
                return FriendlyError(message: error.localizedDescription, action: .retry)
            }
        }

        if let error = error as? VerificationJudgeError {
            switch error {
            case .apiKeyMissing:
                return FriendlyError(message: error.localizedDescription, action: .openSettings)
            case .networkFailure:
                return FriendlyError(message: error.localizedDescription, action: .retry)
            default:
                return FriendlyError(message: error.localizedDescription, action: nil)
            }
        }

        if let error = error as? StreamingCameraError {
            switch error {
            case .missingCredentials, .unauthorized, .invalidConfiguration:
                return FriendlyError(message: error.localizedDescription ?? String(localized: "cameraSetup.error.generic"), action: .manageCameras)
            default:
                return FriendlyError(message: error.localizedDescription ?? String(localized: "cameraSetup.error.generic"), action: nil)
            }
        }

        if let error = error as? CameraFlowError {
            return FriendlyError(message: error.localizedDescription ?? String(localized: "cameraFlow.error.generic"), action: nil)
        }

        if let error = error as? PotError {
            switch error {
            case .insufficientBalance:
                return FriendlyError(message: String(localized: "error.points.insufficient"), action: nil)
            default:
                return FriendlyError(message: String(localized: "error.points.generic"), action: nil)
            }
        }

        return FriendlyError(message: error.localizedDescription, action: nil)
    }
}
