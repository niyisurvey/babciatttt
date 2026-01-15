// AreaDetailView.swift
// BabciaTobiasz

import SwiftUI
#if os(iOS)
import AVFoundation
import UIKit
#endif
import SwiftData

/// Detail view for an Area's Dream header and scan entry.
struct AreaDetailView: View {
    let area: Area
    @Bindable var viewModel: AreaViewModel
    @Environment(\.dsTheme) private var theme

    @State private var headerProgress: CGFloat = 0
    // Added 2026-01-14 20:55 GMT
    @State private var showCameraCapture = false
    @State private var showCameraAlert = false
    @State private var cameraAlertMessage = ""

    var body: some View {
        ZStack {
            backgroundGradient

            ScalingHeaderScrollView(
                maxHeight: theme.grid.heroCardHeight,
                minHeight: 120,  // TODO: Add DSGrid.heroHeaderCollapsedHeight token
                snapMode: .none,
                progress: $headerProgress
            ) { progress in
                dreamHeaderImage(progress: progress)
            } content: {
                VStack(spacing: theme.grid.sectionSpacing) {
                    babciaSparkleCard
                    taskListSection
                }
                .padding()
            }
        }
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        #endif
        .toolbar { toolbarContent }
        .sheet(isPresented: $viewModel.showAreaForm) {
            AreaFormView(viewModel: viewModel, area: viewModel.editingArea)
        }
        // Added 2026-01-14 20:55 GMT
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
        .alert("Camera access", isPresented: $showCameraAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(cameraAlertMessage)
        }
        // Added 2026-01-14 21:13 GMT
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        // Added 2026-01-14 22:02 GMT
        .overlay(alignment: .bottomTrailing) {
            floatingCameraButton
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LiquidGlassBackground(style: .areas)
    }

    // MARK: - Dream Header

    @ViewBuilder
    private func dreamHeaderImage(progress: CGFloat) -> some View {
        dreamHeaderImageView
            .opacity(max(0.0, 1.0 - progress * 1.2))
    }

    @ViewBuilder
    private var dreamHeaderImageView: some View {
        if let data = area.latestBowl?.dreamHeroImageData,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let name = area.dreamImageName {
            Image(name)
                .resizable()
                .scaledToFill()
        } else {
            Image("DreamRoom_Test_1200x1600")
                .resizable()
                .scaledToFill()
        }
    }

    // MARK: - Camera Capture

    // Added 2026-01-14 20:55 GMT
    private func requestCameraCapture() {
#if os(iOS)
        // Added 2026-01-14 21:13 GMT
        if viewModel.isGeneratingDream {
            viewModel.errorMessage = "Dream generation is in progress. Please wait."
            viewModel.showError = true
            return
        }
        if viewModel.isKitchenClosed {
            viewModel.errorMessage = "Kitchen Closed. Daily target reached."
            viewModel.showError = true
            return
        }
        if area.inProgressBowl != nil {
            viewModel.errorMessage = "Finish the current session before starting a new scan."
            viewModel.showError = true
            return
        }
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentCameraAlert("Camera is not available on this device.")
            return
        }

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            showCameraCapture = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCameraCapture = true
                    } else {
                        presentCameraAlert("Camera access is required to capture a room scan.")
                    }
                }
            }
        case .denied, .restricted:
            presentCameraAlert("Camera access is required to capture a room scan.")
        @unknown default:
            presentCameraAlert("Camera access is required to capture a room scan.")
        }
#else
        presentCameraAlert("Camera capture is only available on iOS devices.")
#endif
    }

    // Updated 2026-01-14 22:02 GMT
    private func handleCapturedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            presentCameraAlert("Could not read the captured photo.")
            return
        }
        Task {
            await viewModel.startBowl(
                for: area,
                verificationRequested: false,
                beforePhotoData: data
            )
            hapticFeedback(.medium)
        }
    }

    // Added 2026-01-14 20:55 GMT
    private func presentCameraAlert(_ message: String) {
        cameraAlertMessage = message
        showCameraAlert = true
    }

    // MARK: - Babcia Card

    // Added 2026-01-14 22:02 GMT
    private var babciaSparkleCard: some View {
        GlassCardView {
            HStack(spacing: theme.grid.listSpacing) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(theme.palette.warmAccent)
                            .font(.system(size: theme.grid.iconTitle3))
                            .symbolEffect(.pulse, options: .repeating)
                        Text("Your Babcia")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(area.persona.displayName)
                        .dsFont(.headline, weight: .bold)
                    Text(area.persona.tagline)
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(area.persona.headshotImageName)
                    .resizable()
                    .scaledToFill()
                    // Updated 2026-01-14 22:29 GMT
                    .frame(width: theme.grid.iconXL, height: theme.grid.iconXL)
                    .clipShape(Circle())
            }
            .padding(.vertical, 6)
        }
    }

    // MARK: - Task List

    // Added 2026-01-14 23:20 GMT
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Tasks")
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            GlassCardView {
                VStack(spacing: 0) {
                    ForEach(taskRowItems.indices, id: \.self) { index in
                        taskRow(taskRowItems[index])
                        if index < taskRowItems.count - 1 {
                            Divider().padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }

    // Added 2026-01-14 23:20 GMT
    private var taskRowItems: [CleaningTask?] {
        let pendingTasks = (area.inProgressBowl?.tasks ?? [])
            .filter { !$0.isCompleted }
            .prefix(5)
        let visibleTasks = Array(pendingTasks)
        let placeholders = max(0, 5 - visibleTasks.count)
        return visibleTasks + Array(repeating: nil, count: placeholders)
    }

    // Added 2026-01-14 23:20 GMT
    @ViewBuilder
    private func taskRow(_ task: CleaningTask?) -> some View {
        let title = task?.title ?? "Awaiting scan task"
        let isPlaceholder = task == nil

        Button {
            guard let task else { return }
            withAnimation(theme.motion.listSpring) {
                viewModel.toggleTaskCompletion(task)
            }
            hapticFeedback(.success)
        } label: {
            HStack {
                Text(title)
                    .dsFont(.body)
                    .foregroundStyle(isPlaceholder ? .secondary : .primary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: isPlaceholder ? "circle.dotted" : "sparkles")
                    .font(.system(size: theme.grid.iconTitle3))
                    .foregroundStyle(
                        isPlaceholder
                            ? AnyShapeStyle(.tertiary)
                            : AnyShapeStyle(theme.palette.warmAccent)
                    )
                    .frame(width: 36)

                Image(systemName: isPlaceholder ? "circle" : "checkmark.circle")
                    .dsFont(.headline)
                    .foregroundStyle(
                        isPlaceholder
                            ? AnyShapeStyle(.tertiary)
                            : AnyShapeStyle(theme.palette.warmAccent)
                    )
                    .frame(width: 36, alignment: .trailing)
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isPlaceholder)
        .transition(.opacity.combined(with: .move(edge: .trailing)))
        .accessibilityLabel(title)
    }

    // MARK: - Floating Action

    // Added 2026-01-14 22:02 GMT
    private var floatingCameraButton: some View {
        Button {
            requestCameraCapture()
            hapticFeedback(.medium)
        } label: {
            Label("Take photo", systemImage: "camera")
                .dsFont(.headline)
        }
        .buttonStyle(.nativeGlassProminent)
        .disabled(viewModel.isGeneratingDream || viewModel.isLoading)
        .accessibilityLabel("Take photo")
        .padding(.trailing, theme.grid.sectionSpacing)
        .padding(.bottom, theme.grid.sectionSpacing)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(area.name)
                .dsFont(.headline, weight: .bold)
                .lineLimit(1)
        }
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Button {
                    viewModel.editArea(area)
                } label: {
                    Label("Edit Area", systemImage: "pencil")
                }

                Divider()

                Button(role: .destructive) {
                    viewModel.deleteArea(area)
                } label: {
                    Label("Delete Area", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }

}

#Preview {
    NavigationStack {
        AreaDetailView(area: Area.sampleAreas[0], viewModel: AreaViewModel())
    }
    .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self], inMemory: true)
}
