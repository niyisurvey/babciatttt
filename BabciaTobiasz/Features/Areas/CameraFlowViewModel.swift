//
//  CameraFlowViewModel.swift
//  BabciaTobiasz
//

import Foundation

enum CameraFlowState: Equatable {
    case idle
    case checkingPermission
    case capturing
    case processing(CameraFlowMode)
    case success
    case error(CameraFlowError)
}

enum CameraFlowMode: Equatable {
    case dreamVision
    case appendTasks
    case newTasksOnlyBowl
}

enum CameraFlowError: LocalizedError, Equatable {
    case missingAreaContext
    case streamingCaptureFailed

    var errorDescription: String? {
        switch self {
        case .missingAreaContext:
            return String(localized: "cameraFlow.error.missingArea")
        case .streamingCaptureFailed:
            return String(localized: "cameraFlow.error.streamingCaptureFailed")
        }
    }
}

@MainActor
@Observable
final class CameraFlowViewModel {
    var state: CameraFlowState = .idle

    private weak var areaViewModel: AreaViewModel?

    func configure(areaViewModel: AreaViewModel) {
        self.areaViewModel = areaViewModel
    }

    func determineMode(for area: Area) -> CameraFlowMode {
        if !area.hasDreamVision {
            return .dreamVision
        }
        if area.inProgressBowl != nil {
            return .appendTasks
        }
        return .newTasksOnlyBowl
    }

    func handleCapture(image: Data, for area: Area) async {
        guard let areaViewModel else {
            state = .error(.missingAreaContext)
            return
        }

        let mode = determineMode(for: area)
        state = .processing(mode)

        switch mode {
        case .dreamVision:
            await areaViewModel.startBowl(
                for: area,
                verificationRequested: false,
                beforePhotoData: image
            )
        case .appendTasks:
            await areaViewModel.appendTasks(
                for: area,
                beforePhotoData: image
            )
        case .newTasksOnlyBowl:
            await areaViewModel.startTasksOnlyBowl(
                for: area,
                beforePhotoData: image
            )
        }

        state = .success
    }

    func handleStreamingCapture(provider: StreamingCameraProvider, for area: Area) async {
        do {
            let image = try await provider.captureFrame()
            guard let data = image.jpegData(compressionQuality: 0.85) else {
                state = .error(.streamingCaptureFailed)
                return
            }
            await handleCapture(image: data, for: area)
        } catch {
            state = .error(.streamingCaptureFailed)
        }
    }
}
