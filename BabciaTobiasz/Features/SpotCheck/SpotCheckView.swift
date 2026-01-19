//
//  SpotCheckView.swift
//  BabciaTobiasz
//

import SwiftUI
#if os(iOS)
import AVFoundation
import UIKit
#endif
import SwiftData

struct SpotCheckView: View {
    let onCreateArea: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dsTheme) private var theme
    @Environment(\.appDependencies) private var dependencies

    @State private var viewModel = SpotCheckViewModel()
    @State private var showCameraCapture = false
    @State private var showCameraPermissionPrimer = false
    @State private var showCameraAlert = false
    @State private var cameraAlertMessage = ""
    @State private var didConfigure = false

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    SpotCheckHeaderSection()
                    SpotCheckLimitCard(
                        remaining: max(0, viewModel.spotCheckLimit - viewModel.dailyCount),
                        limit: viewModel.spotCheckLimit,
                        points: viewModel.spotCheckPoints
                    )

                    if viewModel.totalAreaCount == 0 {
                        SpotCheckMinimumAreasCard(
                            currentAreas: viewModel.totalAreaCount,
                            minAreas: viewModel.spotCheckMinAreasRequired,
                            onCreateArea: onCreateArea
                        )
                    } else {
                        quickScanSection
                    }

                    if let result = viewModel.lastResult {
                        SpotCheckResultCard(
                            result: result,
                            areaName: viewModel.lastAreaName,
                            taskCount: viewModel.lastTaskCount,
                            points: viewModel.spotCheckPoints
                        )
                    }

                    if let response = viewModel.lastResponse {
                        SpotCheckResponseCard(response: response)
                    }
                }
                .padding(theme.grid.cardPadding)
            }

            LoadingOverlay(
                message: String(localized: "spotCheck.processing"),
                isLoading: $viewModel.isProcessing
            )
        }
        .alert(String(localized: "spotCheck.camera.alert.title"), isPresented: $showCameraAlert) {
            Button(String(localized: "common.ok"), role: .cancel) {}
        } message: {
            Text(cameraAlertMessage)
        }
        .alert(String(localized: "common.error.title"), isPresented: $viewModel.showError) {
            if let action = viewModel.errorAction {
                Button(action.localizedTitle) {
                    handleErrorAction(action)
                }
            }
            Button(String(localized: "common.ok")) { viewModel.showError = false }
        } message: {
            Text(viewModel.errorMessage ?? String(localized: "common.error.fallback"))
        }
        .fullScreenCover(isPresented: $showCameraCapture) {
            CameraCaptureView(
                onCapture: { image in
                    handleCapturedImage(image)
                    showCameraCapture = false
                },
                onCancel: {
                    showCameraCapture = false
                }
            )
        }
        .fullScreenCover(isPresented: $showCameraPermissionPrimer) {
            CameraPermissionPrimerView(
                title: String(localized: "cameraPermission.title"),
                message: String(localized: "cameraPermission.message"),
                bullets: [
                    String(localized: "cameraPermission.bullet.capture"),
                    String(localized: "cameraPermission.bullet.verify")
                ],
                primaryActionTitle: String(localized: "cameraPermission.action.continue"),
                secondaryActionTitle: String(localized: "cameraPermission.action.notNow"),
                onContinue: { requestCameraPermissionAndCapture() },
                onNotNow: { showCameraPermissionPrimer = false }
            )
        }
        .onAppear {
            if !didConfigure {
                viewModel.configure(
                    modelContext: modelContext,
                    scanPipelineService: dependencies.scanPipelineService
                )
                didConfigure = true
            }
            viewModel.refresh()
        }
    }

    private var quickScanSection: some View {
        VStack(spacing: theme.grid.listSpacing) {
            if viewModel.dailyCount >= viewModel.spotCheckLimit {
                SpotCheckLimitReachedCard()
            } else if viewModel.eligibleAreaCount == 0 {
                SpotCheckCooldownCard(remainingText: viewModel.cooldownRemainingText)
            } else {
                SpotCheckQuickScanCard(onScan: startQuickScan)
            }
        }
    }

    private func startQuickScan() {
        guard viewModel.canDoSpotCheck() else { return }
        viewModel.pickRandomArea()
        guard viewModel.selectedArea != nil else { return }
        requestCameraCapture()
        hapticFeedback(.medium)
    }

    private func requestCameraCapture() {
        guard viewModel.canDoSpotCheck() else { return }
        #if os(iOS)
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentCameraAlert(String(localized: "spotCheck.camera.unavailable"))
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCameraCapture = true
        case .notDetermined:
            showCameraPermissionPrimer = true
        case .denied, .restricted:
            presentCameraAlert(String(localized: "spotCheck.camera.permission"))
        @unknown default:
            presentCameraAlert(String(localized: "spotCheck.camera.permission"))
        }
        #else
        presentCameraAlert(String(localized: "spotCheck.camera.notSupported"))
        #endif
    }

    private func requestCameraPermissionAndCapture() {
        #if os(iOS)
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                showCameraPermissionPrimer = false
                if granted {
                    showCameraCapture = true
                } else {
                    presentCameraAlert(String(localized: "spotCheck.camera.permission"))
                }
            }
        }
        #endif
    }

    private func handleCapturedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            presentCameraAlert(String(localized: "spotCheck.camera.captureFailed"))
            return
        }
        Task {
            await viewModel.performSpotCheck(imageData: data)
            if viewModel.lastResult != nil {
                hapticFeedback(.success)
            }
        }
    }

    private func presentCameraAlert(_ message: String) {
        cameraAlertMessage = message
        showCameraAlert = true
    }

    private func handleErrorAction(_ action: FriendlyErrorAction) {
        switch action {
        case .retry:
            viewModel.refresh()
            viewModel.showError = false
        case .openSettings, .manageCameras:
            AppIntentRoute.store(.settings)
            viewModel.showError = false
        }
    }

}

#Preview {
    SpotCheckView(onCreateArea: {})
        .environment(AppDependencies())
}
