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
    @State private var showReminderPrompt = false
    @State private var cameraFlowViewModel = CameraFlowViewModel()
    @State private var showPierogiDrop = false
    @State private var showVerificationReady = false
    @State private var showVerificationCapture = false
    @State private var showVerificationCelebration = false
    @State private var verificationTier: BowlVerificationTier = .blue
    @State private var verificationPassed: Bool = false
    @State private var verificationBowl: AreaBowl?
    @State private var showDeleteConfirmation = false
    @State private var expandedTaskId: UUID?

    var body: some View {
        ZStack {
            backgroundGradient

            ScalingHeaderScrollView(
                maxHeight: theme.grid.heroCardHeight,
                minHeight: theme.grid.heroHeaderCollapsedHeight,
                snapMode: .none,
                progress: $headerProgress
            ) { progress in
                dreamHeaderImage(progress: progress)
            } content: {
                VStack(spacing: theme.grid.sectionSpacing) {
                    babciaSparkleCard
                    taskListSection
                    verificationCallout
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
        .sheet(isPresented: $showReminderPrompt) {
            RoomReminderPromptView(
                area: area,
                onStart: {
                    showReminderPrompt = false
                    requestCameraCapture()
                },
                onDismiss: {
                    showReminderPrompt = false
                }
            )
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
        .fullScreenCover(isPresented: $showVerificationCapture) {
            CameraCaptureView(
                onCapture: { image in
                    handleVerificationCapturedImage(image)
                    showVerificationCapture = false
                },
                onCancel: {
                    showVerificationCapture = false
                }
            )
        }
        .alert(String(localized: "areaDetail.camera.alert.title"), isPresented: $showCameraAlert) {
            Button(String(localized: "common.ok"), role: .cancel) {}
        } message: {
            Text(cameraAlertMessage)
        }
        .fullScreenCover(isPresented: $showPierogiDrop) {
            PierogiDropView(tier: verificationTier) { tier in
                verificationTier = tier
                showPierogiDrop = false
                showVerificationReady = true
            }
        }
        .alert(String(localized: "areaDetail.verify.ready.title"), isPresented: $showVerificationReady) {
            Button(String(localized: "areaDetail.verify.ready.primary")) { showVerificationCapture = true }
            Button(String(localized: "areaDetail.verify.ready.secondary"), role: .cancel) { markVerificationPending() }
        } message: {
            Text(verificationReadyMessage)
        }
        .alert(verificationCelebrationTitle, isPresented: $showVerificationCelebration) {
            Button(String(localized: "common.ok"), role: .cancel) { }
        } message: {
            Text(verificationCelebrationMessage)
        }
        .alert(String(localized: "areaDetail.delete.title"), isPresented: $showDeleteConfirmation) {
            Button(String(localized: "common.delete"), role: .destructive) { viewModel.deleteArea(area) }
            Button(String(localized: "common.cancel"), role: .cancel) { }
        } message: {
            Text(deleteWarningMessage)
        }
        // Added 2026-01-14 21:13 GMT
        .alert(String(localized: "common.error.title"), isPresented: $viewModel.showError) {
            Button(String(localized: "common.ok")) { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? String(localized: "common.error.fallback"))
        }
        // Added 2026-01-14 22:02 GMT
        .overlay(alignment: .bottomTrailing) {
            floatingCameraButton
        }
        .onAppear {
            cameraFlowViewModel.configure(areaViewModel: viewModel)
            if viewModel.consumeReminderPrompt(for: area.id) {
                showReminderPrompt = true
            }
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
        } else if let name = area.dreamImageName,
                  let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let fallbackImage = UIImage(named: "DreamRoom_Test_1200x1600") {
            Image(uiImage: fallbackImage)
                .resizable()
                .scaledToFill()
        } else {
            Rectangle()
                .fill(.clear)
        }
    }

    // MARK: - Camera Capture

    // Added 2026-01-14 20:55 GMT
    private func requestCameraCapture() {
#if os(iOS)
        // Added 2026-01-14 21:13 GMT
        if isVerificationDecisionPending {
            viewModel.errorMessage = String(localized: "areaDetail.camera.error.verificationPending")
            viewModel.showError = true
            return
        }
        if viewModel.isGeneratingDream {
            viewModel.errorMessage = String(localized: "areaDetail.camera.error.dreamInProgress")
            viewModel.showError = true
            return
        }
        if viewModel.isKitchenClosed {
            viewModel.errorMessage = String(localized: "areaDetail.camera.error.kitchenClosed")
            viewModel.showError = true
            return
        }
        let flowMode = cameraFlowViewModel.determineMode(for: area)
        if area.inProgressBowl != nil, flowMode != .appendTasks {
            viewModel.errorMessage = String(localized: "areaDetail.camera.error.finishCurrent")
            viewModel.showError = true
            return
        }
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentCameraAlert(String(localized: "areaDetail.camera.error.unavailable"))
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
                        presentCameraAlert(String(localized: "areaDetail.camera.error.permission"))
                    }
                }
            }
        case .denied, .restricted:
            presentCameraAlert(String(localized: "areaDetail.camera.error.permission"))
        @unknown default:
            presentCameraAlert(String(localized: "areaDetail.camera.error.permission"))
        }
#else
        presentCameraAlert(String(localized: "areaDetail.camera.error.notSupported"))
#endif
    }

    // Updated 2026-01-14 22:02 GMT
    private func handleCapturedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            presentCameraAlert(String(localized: "areaDetail.camera.error.captureFailed"))
            return
        }
        Task {
            await cameraFlowViewModel.handleCapture(image: data, for: area)
            hapticFeedback(.medium)
        }
    }

    // Added 2026-01-14 20:55 GMT
    private func presentCameraAlert(_ message: String) {
        cameraAlertMessage = message
        showCameraAlert = true
    }

    private var deleteWarningMessage: String {
        if let milestone = viewModel.milestone(for: area) {
            return String(format: String(localized: "areaDetail.delete.message.milestone"), milestone.day)
        }
        return String(localized: "areaDetail.delete.message.default")
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
                    Text(String(localized: "areaDetail.babcia.label"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
                    Text(area.persona.localizedDisplayName)
                        .dsFont(.headline, weight: .bold)
                    Text(area.persona.localizedTagline)
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                personaHeadshotView
            }
            .padding(.vertical, 6)
        }
    }

    @ViewBuilder
    private var personaHeadshotView: some View {
        if let uiImage = UIImage(named: area.persona.headshotImageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: theme.grid.iconXL, height: theme.grid.iconXL)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .fill(theme.glass.strength.fallbackMaterial)
                Image(systemName: "person.fill")
                    .font(.system(size: theme.grid.iconMedium))
                    .foregroundStyle(theme.palette.secondary)
            }
            .frame(width: theme.grid.iconXL, height: theme.grid.iconXL)
        }
    }

    // MARK: - Task List

    // Added 2026-01-14 23:20 GMT
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "areaDetail.tasks.title"))
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


    @ViewBuilder
    private func taskStatusSymbol(isPlaceholder: Bool) -> some View {
        if isPlaceholder {
            SafeSystemImage("circle.dotted", fallback: "circle")
        } else {
            Image(systemName: "sparkles")
        }
    }

    // Added 2026-01-14 23:20 GMT
    @ViewBuilder
    private func taskRow(_ task: CleaningTask?) -> some View {
        let isPlaceholder = task == nil
        if let task {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .dsFont(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    taskStatusSymbol(isPlaceholder: false)
                        .font(.system(size: theme.grid.iconTitle3))
                        .foregroundStyle(theme.palette.warmAccent)
                        .frame(width: 36)

                    Button {
                        withAnimation(theme.motion.listSpring) {
                            viewModel.toggleTaskCompletion(task)
                        }
                        hapticFeedback(.success)
                        checkForVerificationPrompt()
                    } label: {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                            .dsFont(.headline)
                            .foregroundStyle(theme.palette.warmAccent)
                            .frame(width: 36, alignment: .trailing)
                    }
                    .buttonStyle(.plain)
                    .disabled(task.isCompleted)
                }
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(theme.motion.listSpring) {
                        expandedTaskId = (expandedTaskId == task.id) ? nil : task.id
                    }
                }

                if expandedTaskId == task.id {
                    Text(task.title)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
            }
            .transition(.opacity.combined(with: .move(edge: .trailing)))
            .accessibilityLabel(task.title)
        } else {
            HStack {
                Spacer()
                taskStatusSymbol(isPlaceholder: true)
                    .font(.system(size: theme.grid.iconTitle3))
                    .foregroundStyle(.tertiary)
                    .frame(width: 36)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Verification Callout

    @ViewBuilder
    private var verificationCallout: some View {
        if let bowl = area.latestBowl, bowl.isCompleted, isVerificationDecisionPending {
            GlassCardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "areaDetail.verify.callout.title"))
                        .dsFont(.headline, weight: .bold)
                    Text(String(localized: "areaDetail.verify.callout.message"))
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)
                    Button {
                        beginVerificationFlow()
                    } label: {
                        Label(String(localized: "areaDetail.verify.callout.primary"), systemImage: "checkmark.seal.fill")
                            .dsFont(.headline)
                    }
                    .buttonStyle(.nativeGlassProminent)
                    .padding(.top, 4)
                    Button {
                        takeBasePointsOnly()
                    } label: {
                        Label(String(localized: "areaDetail.verify.callout.secondary"), systemImage: "checkmark")
                            .dsFont(.subheadline, weight: .bold)
                    }
                    .buttonStyle(.nativeGlass)
                }
                .padding()
            }
        }
    }

    // MARK: - Floating Action

    // Added 2026-01-14 22:02 GMT
    private var floatingCameraButton: some View {
        Button {
            requestCameraCapture()
            hapticFeedback(.medium)
        } label: {
            Label(String(localized: "areaDetail.camera.checkIn"), systemImage: "camera")
                .dsFont(.headline)
        }
        .buttonStyle(.nativeGlassProminent)
        .disabled(viewModel.isGeneratingDream || viewModel.isLoading)
        .accessibilityLabel(String(localized: "areaDetail.camera.checkIn"))
        .padding(.trailing, theme.grid.sectionSpacing)
        .padding(.bottom, theme.grid.sectionSpacing)
    }

    // MARK: - Verification Flow

    private func checkForVerificationPrompt() {
        guard let bowl = area.latestBowl else { return }
        guard bowl.isCompleted, bowl.verificationRequested == false else { return }
        guard showPierogiDrop == false else { return }
        verificationBowl = bowl
        verificationTier = viewModel.isGoldenEligible() ? .golden : .blue
        showPierogiDrop = true
    }

    private var isVerificationDecisionPending: Bool {
        guard let bowl = area.latestBowl else { return false }
        return bowl.verificationRequested && bowl.verificationOutcome == .pending
    }

    private func markVerificationPending() {
        guard let bowl = verificationBowl ?? area.latestBowl else { return }
        viewModel.markVerificationDecisionPending(for: bowl)
    }

    private func takeBasePointsOnly() {
        guard let bowl = area.latestBowl else { return }
        viewModel.skipVerification(for: bowl)
    }

    private func beginVerificationFlow() {
        verificationTier = viewModel.isGoldenEligible() ? .golden : .blue
        showVerificationReady = true
    }

    private func handleVerificationCapturedImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            presentCameraAlert(String(localized: "areaDetail.camera.error.captureFailed"))
            return
        }
        guard let bowl = verificationBowl else { return }
        Task {
            do {
                let passed = try await viewModel.submitVerification(
                    for: bowl,
                    tier: verificationTier,
                    afterPhotoData: data
                )
                verificationPassed = passed
                hapticFeedback(passed ? .success : .warning)
                showVerificationCelebration = true
            } catch {
                viewModel.errorMessage = error.localizedDescription
                viewModel.showError = true
            }
        }
    }

    private var verificationCelebrationTitle: String {
        if verificationPassed {
            return verificationTier == .golden
                ? String(localized: "areaDetail.verify.celebration.title.golden")
                : String(localized: "areaDetail.verify.celebration.title.blue")
        }
        return String(localized: "areaDetail.verify.celebration.title.failed")
    }

    private var verificationCelebrationMessage: String {
        if verificationPassed {
            return verificationTier == .golden
                ? String(localized: "areaDetail.verify.celebration.message.golden")
                : String(localized: "areaDetail.verify.celebration.message.blue")
        }
        return String(localized: "areaDetail.verify.celebration.message.failed")
    }

    private var verificationReadyMessage: String {
        verificationTier == .golden
            ? String(localized: "areaDetail.verify.ready.message.golden")
            : String(localized: "areaDetail.verify.ready.message.blue")
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
                    Label(String(localized: "areaDetail.menu.edit"), systemImage: "pencil")
                }

                Divider()

                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label(String(localized: "areaDetail.menu.delete"), systemImage: "trash")
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
    .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self], inMemory: true)
    .environment(AppDependencies())
}
