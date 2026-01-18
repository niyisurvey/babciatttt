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
    @State private var showCameraAlert = false
    @State private var cameraAlertMessage = ""
    @State private var didConfigure = false
    @State private var isRevealing = false
    @State private var revealTask: Task<Void, Never>?

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

                    if !viewModel.meetsMinimumAreas {
                        SpotCheckMinimumAreasCard(
                            minAreas: viewModel.spotCheckMinAreasRequired,
                            onCreateArea: onCreateArea
                        )
                    } else {
                        revealSection
                        SpotCheckAreaCard(area: viewModel.selectedArea)
                        actionSection
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
        .onDisappear {
            revealTask?.cancel()
        }
    }

    private var revealSection: some View {
        VStack(spacing: theme.grid.listSpacing) {
            if viewModel.dailyCount >= viewModel.spotCheckLimit {
                SpotCheckLimitReachedCard()
            } else if viewModel.eligibleAreaCount == 0 {
                SpotCheckCooldownCard()
            } else if isRevealing {
                SpotCheckRevealView(message: String(localized: "spotCheck.reveal.message"))
            } else {
                SpotCheckRevealCard(onReveal: revealArea)
            }
        }
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            if viewModel.canDoSpotCheck(), viewModel.selectedArea != nil, !isRevealing {
                Button {
                    requestCameraCapture()
                    hapticFeedback(.medium)
                } label: {
                    Label(String(localized: "spotCheck.action.camera"), systemImage: "camera")
                        .dsFont(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.nativeGlassProminent)
            } else if viewModel.meetsMinimumAreas, viewModel.dailyCount < viewModel.spotCheckLimit {
                SpotCheckAwaitingCard()
            }
        }
    }

    private func revealArea() {
        guard viewModel.canRevealArea() else { return }
        revealTask?.cancel()
        isRevealing = true
        viewModel.clearSelection()
        let delaySeconds = theme.motion.shimmerDuration
        revealTask = Task { @MainActor in
            let delay = UInt64(delaySeconds * 1_000_000_000)
            try? await Task.sleep(nanoseconds: delay)
            guard !Task.isCancelled else { return }
            viewModel.pickRandomArea()
            withAnimation(theme.motion.listSpring) {
                isRevealing = false
            }
            hapticFeedback(.medium)
        }
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
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCameraCapture = true
                    } else {
                        presentCameraAlert(String(localized: "spotCheck.camera.permission"))
                    }
                }
            }
        case .denied, .restricted:
            presentCameraAlert(String(localized: "spotCheck.camera.permission"))
        @unknown default:
            presentCameraAlert(String(localized: "spotCheck.camera.permission"))
        }
        #else
        presentCameraAlert(String(localized: "spotCheck.camera.notSupported"))
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

}

#Preview {
    SpotCheckView(onCreateArea: {})
        .environment(AppDependencies())
}
