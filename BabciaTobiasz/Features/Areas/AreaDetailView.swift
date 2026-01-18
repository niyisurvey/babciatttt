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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dsTheme) private var theme
    @Query private var reminderConfigs: [ReminderConfig]

    @State private var headerProgress: CGFloat = 0
    // Added 2026-01-14 20:55 GMT
    @State private var showCameraCapture = false
    @State private var showCameraHeroPrompt = false
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
    @State private var streamingManager = StreamingCameraManager()
    @State private var showVerificationSourcePicker = false
    @State private var showStreamingCameraPicker = false
    @State private var isStreamingCaptureLoading = false
    @State private var showCameraSourcePicker = false
    @State private var showStreamingCameraPickerForScan = false
    @AppStorage("areaDetail.taskTapHintShown") private var taskTapHintShown = false
    @State private var showTaskTapHint = false
    @State private var showCompletionSummary = false
    @AppStorage("needsFirstScan") private var needsFirstScan = false

    init(area: Area, viewModel: AreaViewModel) {
        self.area = area
        self._viewModel = Bindable(wrappedValue: viewModel)
        let areaId = area.id
        _reminderConfigs = Query(filter: #Predicate<ReminderConfig> { $0.areaId == areaId })
    }

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
        .fullScreenCover(isPresented: $showCameraHeroPrompt) {
            CameraHeroPromptView(
                area: area,
                onStart: {
                    showCameraHeroPrompt = false
                    startCameraCapture()
                },
                onDismiss: {
                    showCameraHeroPrompt = false
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
            PierogiDropView(tier: verificationTier, autoReveal: true) { tier in
                verificationTier = tier
                showPierogiDrop = false
                showCompletionSummary = true
            }
        }
        .fullScreenCover(isPresented: $showCompletionSummary) {
            CompletionSummaryView(
                persona: area.persona,
                tier: verificationTier,
                onVerify: {
                    showCompletionSummary = false
                    showVerificationSourcePicker = true
                },
                onDone: {
                    showCompletionSummary = false
                    AppExitHelper.requestExit()
                }
            )
        }
        .alert(String(localized: "areaDetail.verify.ready.title"), isPresented: $showVerificationReady) {
            Button(String(localized: "areaDetail.verify.ready.primary")) { showVerificationSourcePicker = true }
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
        .confirmationDialog(
            String(localized: "cameraSource.title"),
            isPresented: $showVerificationSourcePicker,
            titleVisibility: .visible
        ) {
            Button(String(localized: "cameraSource.device")) { showVerificationCapture = true }
            if !streamingManager.configs.isEmpty {
                Button(String(localized: "cameraSource.streaming")) { showStreamingCameraPicker = true }
            }
            Button(String(localized: "common.cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "cameraSource.message"))
        }
        .confirmationDialog(
            String(localized: "cameraSource.title"),
            isPresented: $showCameraSourcePicker,
            titleVisibility: .visible
        ) {
            Button(String(localized: "cameraSource.device")) { requestDeviceCameraCapture() }
            Button(String(localized: "cameraSource.streaming")) { showStreamingCameraPickerForScan = true }
            Button(String(localized: "common.cancel"), role: .cancel) { }
        } message: {
            Text(String(localized: "cameraSource.message"))
        }
        .sheet(isPresented: $showStreamingCameraPicker) {
            StreamingCameraPickerView(
                cameras: streamingManager.configs,
                onSelect: { config in
                    showStreamingCameraPicker = false
                    handleStreamingVerificationCapture(config)
                },
                onCancel: { showStreamingCameraPicker = false }
            )
        }
        .sheet(isPresented: $showStreamingCameraPickerForScan) {
            StreamingCameraPickerView(
                cameras: streamingManager.configs,
                onSelect: { config in
                    showStreamingCameraPickerForScan = false
                    handleStreamingScanCapture(config)
                },
                onCancel: { showStreamingCameraPickerForScan = false }
            )
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
        .overlay {
            LoadingOverlay(
                message: String(localized: "cameraSource.loading"),
                isLoading: $isStreamingCaptureLoading
            )
        }
        .overlay {
            if viewModel.isGeneratingDream {
                ScanProcessingOverlayView(persona: area.persona)
            }
        }
        .onAppear {
            cameraFlowViewModel.configure(areaViewModel: viewModel)
            streamingManager.configure(modelContext: modelContext)
            streamingManager.loadConfigs()
            if viewModel.consumeReminderPrompt(for: area.id) {
                showReminderPrompt = true
            }
            if needsFirstScan, area.latestBowl == nil, showReminderPrompt == false {
                needsFirstScan = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    requestCameraCapture()
                }
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
        if let data = area.latestDreamBowl?.dreamHeroImageData,
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
        if !streamingManager.configs.isEmpty {
            showCameraSourcePicker = true
        } else {
            requestDeviceCameraCapture()
        }
#else
        presentCameraAlert(String(localized: "areaDetail.camera.error.notSupported"))
#endif
    }

    private func requestDeviceCameraCapture() {
#if os(iOS)
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            presentCameraAlert(String(localized: "areaDetail.camera.error.unavailable"))
            return
        }
        showCameraHeroPrompt = true
#else
        presentCameraAlert(String(localized: "areaDetail.camera.error.notSupported"))
#endif
    }

    private func startCameraCapture() {
#if os(iOS)
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
        Task { @MainActor in
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
                    reminderPreviewRow
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
                .frame(width: theme.grid.iconXXXL, height: theme.grid.iconXXXL)
                .clipShape(Circle())
        } else {
            ZStack {
                Circle()
                    .fill(theme.glass.strength.fallbackMaterial)
                Image(systemName: "person.fill")
                    .font(.system(size: theme.grid.iconXL))
                    .foregroundStyle(theme.palette.secondary)
            }
            .frame(width: theme.grid.iconXXXL, height: theme.grid.iconXXXL)
        }
    }

    private var reminderPreviewRow: some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.badge")
                .font(.system(size: theme.grid.iconTiny))
                .foregroundStyle(.secondary)
            Text(String(localized: "reminders.preview.label"))
                .dsFont(.caption2)
                .foregroundStyle(.secondary)
            Text(reminderTimesText)
                .dsFont(.caption2, weight: .bold)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var reminderTimesText: String {
        guard let config = reminderConfigs.first,
              config.isEnabled,
              !config.activeSlotTimes.isEmpty else {
            return String(localized: "reminders.preview.off")
        }

        return config.activeSlotTimes
            .sorted()
            .map { $0.formatted(date: .omitted, time: .shortened) }
            .joined(separator: " • ")
    }

    // MARK: - Task List

    // Added 2026-01-14 23:20 GMT
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "areaDetail.tasks.title"))
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            TaskPierogiDropCard(
                tasks: taskDropTasks,
                goldenChancePercent: AppConfigService.shared.pierogiGoldenChancePercent
            ) { task in
                withAnimation(theme.motion.listSpring) {
                    viewModel.toggleTaskCompletion(task)
                }
                hapticFeedback(.success)
                checkForVerificationPrompt()
            } onToggleTask: { task in
                withAnimation(theme.motion.listSpring) {
                    viewModel.toggleTaskCompletion(task)
                }
                hapticFeedback(.selection)
                checkForVerificationPrompt()
            }
        }
        .overlay(alignment: .topLeading) {
            if showTaskTapHint {
                FeatureTooltip(
                    title: String(localized: "areaDetail.tasks.hint.title"),
                    description: String(localized: "areaDetail.tasks.hint.message"),
                    icon: "hand.tap.fill",
                    isVisible: $showTaskTapHint
                )
                .offset(x: 12, y: -8)
            }
        }
        .onAppear {
            if taskTapHintShown == false, taskDropTasks.isEmpty == false {
                showTaskTapHint = true
            }
        }
        .onChange(of: showTaskTapHint) { _, isVisible in
            if isVisible == false {
                taskTapHintShown = true
            }
        }
    }

    private var taskDropTasks: [CleaningTask] {
        let tasks = area.inProgressBowl?.tasks ?? []
        return Array(tasks.sorted { $0.createdAt < $1.createdAt }.prefix(5))
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

    private func handleStreamingVerificationCapture(_ config: StreamingCameraConfig) {
        Task {
            isStreamingCaptureLoading = true
            defer { isStreamingCaptureLoading = false }
            do {
                let image = try await streamingManager.captureFrame(for: config)
                handleVerificationCapturedImage(image)
            } catch {
                viewModel.errorMessage = error.localizedDescription
                viewModel.showError = true
            }
        }
    }

    private func handleStreamingScanCapture(_ config: StreamingCameraConfig) {
        Task { @MainActor in
            isStreamingCaptureLoading = true
            defer { isStreamingCaptureLoading = false }
            do {
                let provider = try streamingManager.provider(for: config)
                await cameraFlowViewModel.handleStreamingCapture(provider: provider, for: area)
                hapticFeedback(.medium)
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
    .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self, StreamingCameraConfig.self], inMemory: true)
    .environment(AppDependencies())
}
