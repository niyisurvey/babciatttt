//
//  MicroTidyView.swift
//  BabciaTobiasz
//

import SwiftUI
#if os(iOS)
import AVFoundation
import UIKit
#endif
import SwiftData

struct MicroTidyView: View {
    let onOpenAreas: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dsTheme) private var theme

    @State private var viewModel = MicroTidyViewModel()
    @State private var showCameraCapture = false
    @State private var showCameraAlert = false
    @State private var cameraAlertMessage = ""
    @State private var didConfigure = false

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerSection
                    limitSection

                    if viewModel.areas.isEmpty {
                        emptyStateCard
                    } else {
                        areaSelectionCard
                        actionSection
                    }

                    if let response = viewModel.lastResponse {
                        responseCard(response)
                    }
                }
                .padding(theme.grid.cardPadding)
            }
        }
        .alert(String(localized: "microTidy.camera.alert.title"), isPresented: $showCameraAlert) {
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
                viewModel.configure(modelContext: modelContext)
                didConfigure = true
            }
            viewModel.refresh()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Text(String(localized: "microTidy.title"))
                .dsFont(.title2, weight: .bold)
            Text(String(localized: "microTidy.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var limitSection: some View {
        let remaining = max(0, viewModel.microTidyLimit - viewModel.dailyCount)
        return GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "microTidy.limit.title"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: String(localized: "microTidy.limit.status"), remaining, viewModel.microTidyLimit))
                    .dsFont(.headline, weight: .bold)
                Text(String(format: String(localized: "microTidy.points.reward"), viewModel.microTidyPoints))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var emptyStateCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "microTidy.empty.title"))
                    .dsFont(.headline, weight: .bold)
                Text(String(localized: "microTidy.empty.message"))
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                Button {
                    onOpenAreas()
                    hapticFeedback(.selection)
                } label: {
                    Label(String(localized: "microTidy.empty.action"), systemImage: "plus.circle.fill")
                        .dsFont(.headline)
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var areaSelectionCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "microTidy.area.title"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                if let area = viewModel.selectedArea {
                    Text(area.name)
                        .dsFont(.headline, weight: .bold)
                    Text(area.persona.localizedDisplayName)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)

                    if viewModel.areas.count > 1 {
                        Text(String(localized: "microTidy.area.randomPrompt"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(localized: "microTidy.area.singlePrompt"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            if viewModel.canDoMicroTidy() {
                Button {
                    requestCameraCapture()
                    hapticFeedback(.medium)
                } label: {
                    Label(String(localized: "microTidy.action.camera"), systemImage: "camera")
                        .dsFont(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.nativeGlassProminent)
            } else {
                GlassCardView {
                    Text(String(localized: "microTidy.limit.reached"))
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func responseCard(_ response: String) -> some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "microTidy.response.title"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                Text(response)
                    .dsFont(.headline, weight: .bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func requestCameraCapture() {
        guard viewModel.canDoMicroTidy() else { return }
        #if os(iOS)
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentCameraAlert(String(localized: "microTidy.camera.unavailable"))
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
                        presentCameraAlert(String(localized: "microTidy.camera.permission"))
                    }
                }
            }
        case .denied, .restricted:
            presentCameraAlert(String(localized: "microTidy.camera.permission"))
        @unknown default:
            presentCameraAlert(String(localized: "microTidy.camera.permission"))
        }
        #else
        presentCameraAlert(String(localized: "microTidy.camera.notSupported"))
        #endif
    }

    private func handleCapturedImage(_ image: UIImage) {
        guard image.jpegData(compressionQuality: 0.85) != nil else {
            presentCameraAlert(String(localized: "microTidy.camera.captureFailed"))
            return
        }
        viewModel.completeMicroTidy()
        hapticFeedback(.success)
    }

    private func presentCameraAlert(_ message: String) {
        cameraAlertMessage = message
        showCameraAlert = true
    }
}

#Preview {
    MicroTidyView(onOpenAreas: {})
        .environment(AppDependencies())
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self, StreamingCameraConfig.self], inMemory: true)
}
