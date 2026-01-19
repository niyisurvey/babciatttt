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
    @State private var showCameraPermissionPrimer = false
    @State private var showCameraAlert = false
    @State private var cameraAlertMessage = ""
    @State private var showReminderPrompt = false
    @State private var cameraFlowViewModel = CameraFlowViewModel()
    @State private var showVerificationCapture = false
    @State private var showVerificationCelebration = false
    @State private var showExitPrompt = false
    @State private var verificationTier: BowlVerificationTier = .blue
    @State private var verificationPassed: Bool = false
    @State private var verificationBowl: AreaBowl?
    @State private var showDeleteConfirmation = false
    @State private var streamingManager = StreamingCameraManager()
    @State private var showStreamingCameraPicker = false
    @State private var isStreamingCaptureLoading = false
    @State private var showCameraSourcePicker = false
    @State private var showStreamingCameraPickerForScan = false
    @State private var showVerificationSourcePicker = false
    @State private var prefersLinkedCamera = false
    @AppStorage("areaDetail.taskTapHintShown") private var taskTapHintShown = false
    @AppStorage("areaDetail.taskExplanationShown") private var taskExplanationShown = false
    @State private var showTaskTapHint = false
    @State private var showTaskExplanation = false
    @State private var showCameraSetup = false
    @State private var pendingCameraPermissionTarget: CameraPermissionTarget?
    @State private var taskUndoSnapshot: AreaViewModel.TaskUndoSnapshot?
    @State private var showTaskUndoToast = false
    @State private var taskUndoTask: Task<Void, Never>?
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
                    kitchenClosedCard
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
                    startCameraCapture(for: .scan)
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
                onNotNow: {
                    showCameraPermissionPrimer = false
                    pendingCameraPermissionTarget = nil
                }
            )
        }
        .alert(String(localized: "areaDetail.camera.alert.title"), isPresented: $showCameraAlert) {
            Button(String(localized: "common.ok"), role: .cancel) {}
        } message: {
            Text(cameraAlertMessage)
        }
        .alert(verificationCelebrationTitle, isPresented: $showVerificationCelebration) {
            Button(String(localized: "common.ok"), role: .cancel) { }
        } message: {
            Text(verificationCelebrationMessage)
        }
        .alert(String(localized: "areaDetail.exitPrompt.title"), isPresented: $showExitPrompt) {
            Button(String(localized: "areaDetail.exitPrompt.primary")) { AppExitHelper.requestExit() }
            Button(String(localized: "areaDetail.exitPrompt.secondary"), role: .cancel) { }
        } message: {
            Text(String(localized: "areaDetail.exitPrompt.message"))
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
            Button(String(localized: "cameraSource.device")) { startCameraCapture(for: .verification) }
            if let linkedCamera = linkedStreamingCamera {
                Button(String(format: String(localized: "cameraSource.linked"), linkedCamera.name)) {
                    handleStreamingVerificationCapture(linkedCamera)
                }
            }
            if streamingManager.configs.isEmpty {
                Button(String(localized: "cameraSource.addStreaming")) { showCameraSetup = true }
            } else {
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
            if let linkedCamera = linkedStreamingCamera {
                Button(String(format: String(localized: "cameraSource.linked"), linkedCamera.name)) {
                    handleStreamingScanCapture(linkedCamera)
                }
            }
            if streamingManager.configs.isEmpty {
                Button(String(localized: "cameraSource.addStreaming")) { showCameraSetup = true }
            } else {
                Button(String(localized: "cameraSource.streaming")) { showStreamingCameraPickerForScan = true }
            }
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
        .sheet(isPresented: $showCameraSetup) {
            NavigationStack {
                CameraSetupView()
            }
        }
        // Added 2026-01-14 21:13 GMT
        .alert(String(localized: "common.error.title"), isPresented: $viewModel.showError) {
            if let action = viewModel.errorAction {
                Button(action.localizedTitle) {
                    handleErrorAction(action)
                }
            }
            Button(String(localized: "common.ok")) { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? String(localized: "common.error.fallback"))
        }
        // Added 2026-01-14 22:02 GMT
        .overlay(alignment: .bottomTrailing) {
            floatingCameraButton
        }
        .overlay(alignment: .bottom) {
            if showTaskUndoToast, let snapshot = taskUndoSnapshot {
                ToastBannerView(
                    message: String(localized: "areaDetail.tasks.undo.message"),
                    actionTitle: String(localized: "areaDetail.tasks.undo.action"),
                    onAction: {
                        viewModel.undoTaskCompletion(snapshot)
                        hapticFeedback(.light)
                        hideTaskUndoToast()
                    },
                    onDismiss: { hideTaskUndoToast() }
                )
                .padding(.horizontal, theme.grid.cardPadding)
                .padding(.bottom, theme.grid.sectionSpacing * 2)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
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
        if let uiImage = UIImage(named: areaHeroImageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            DreamHeaderPlaceholderView(
                title: String(localized: "areaDetail.hero.placeholder.title"),
                message: String(localized: "areaDetail.hero.placeholder.message"),
                icon: "camera.fill"
            )
        }
    }

    private var areaHeroImageName: String {
        let persona = area.persona
        if area.latestBowl == nil {
            return persona.portraitThinkingImageName
        }
        if area.inProgressBowl != nil {
            return persona.fullBodyImageName(for: .happy)
        }
        if area.latestBowl?.isCompleted == true {
            return persona.fullBodyImageName(for: .victory)
        }
        return persona.fullBodyImageName(for: .happy)
    }

    // MARK: - Camera Capture

    // Added 2026-01-14 20:55 GMT
    private func requestCameraCapture() {
#if os(iOS)
        // Added 2026-01-14 21:13 GMT
        if isVerificationDecisionPending {
            return
        }
        if viewModel.isGeneratingDream {
            viewModel.errorMessage = String(localized: "areaDetail.camera.error.dreamInProgress")
            viewModel.showError = true
            return
        }
        if viewModel.isKitchenClosed {
            return
        }
        let flowMode = cameraFlowViewModel.determineMode(for: area)
        if area.inProgressBowl != nil, flowMode != .appendTasks {
            viewModel.errorMessage = String(localized: "areaDetail.camera.error.finishCurrent")
            viewModel.showError = true
            return
        }
        startDefaultScanCapture()
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

    private func startDefaultScanCapture() {
        if prefersLinkedCamera, let linkedCamera = linkedStreamingCamera {
            handleStreamingScanCapture(linkedCamera)
        } else {
            requestDeviceCameraCapture()
        }
    }

    private func startDefaultVerificationCapture() {
        if prefersLinkedCamera, let linkedCamera = linkedStreamingCamera {
            handleStreamingVerificationCapture(linkedCamera)
        } else {
            startCameraCapture(for: .verification)
        }
    }

    private func startCameraCapture(for target: CameraPermissionTarget) {
#if os(iOS)
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            openCameraCapture(for: target)
        case .notDetermined:
            pendingCameraPermissionTarget = target
            showCameraPermissionPrimer = true
        case .denied, .restricted:
            presentCameraAlert(String(localized: "areaDetail.camera.error.permission"))
        @unknown default:
            presentCameraAlert(String(localized: "areaDetail.camera.error.permission"))
        }
#else
        presentCameraAlert(String(localized: "areaDetail.camera.error.notSupported"))
#endif
    }

    private func requestCameraPermissionAndCapture() {
#if os(iOS)
        let target = pendingCameraPermissionTarget
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                showCameraPermissionPrimer = false
                pendingCameraPermissionTarget = nil
                if granted, let target {
                    openCameraCapture(for: target)
                } else if !granted {
                    presentCameraAlert(String(localized: "areaDetail.camera.error.permission"))
                }
            }
        }
#endif
    }

    private func openCameraCapture(for target: CameraPermissionTarget) {
        switch target {
        case .scan:
            showCameraCapture = true
        case .verification:
            showVerificationCapture = true
        }
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

    private func completeTask(_ task: CleaningTask, haptic: HapticStyle) {
        if let snapshot = viewModel.toggleTaskCompletion(task) {
            showTaskUndoToast(snapshot)
        }
        hapticFeedback(haptic)
        checkForVerificationPrompt()
    }

    private func showTaskUndoToast(_ snapshot: AreaViewModel.TaskUndoSnapshot) {
        taskUndoSnapshot = snapshot
        showTaskUndoToast = true
        taskUndoTask?.cancel()
        taskUndoTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(4))
            hideTaskUndoToast()
        }
    }

    private func hideTaskUndoToast() {
        taskUndoTask?.cancel()
        taskUndoTask = nil
        showTaskUndoToast = false
    }

    // Added 2026-01-14 20:55 GMT
    private func presentCameraAlert(_ message: String) {
        cameraAlertMessage = message
        showCameraAlert = true
    }

    private func handleErrorAction(_ action: FriendlyErrorAction) {
        switch action {
        case .retry:
            viewModel.dismissError()
        case .openSettings, .manageCameras:
            AppIntentRoute.store(.settings)
            viewModel.dismissError()
        }
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

    private var linkedStreamingCamera: StreamingCameraConfig? {
        guard let linkedId = area.streamingCameraId else { return nil }
        return streamingManager.configs.first { $0.id == linkedId }
    }

    @ViewBuilder
    private func cameraSourceControls(showPicker: Binding<Bool>) -> some View {
        let hasLinkedCamera = linkedStreamingCamera != nil
        if hasLinkedCamera || streamingManager.configs.isEmpty == false {
            VStack(alignment: .leading, spacing: 6) {
                if let linkedCamera = linkedStreamingCamera {
                    Toggle(isOn: $prefersLinkedCamera) {
                        Text(String(format: String(localized: "cameraSource.linked"), linkedCamera.name))
                            .dsFont(.caption)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: theme.palette.primary))
                }
                Button(String(localized: "cameraSource.choose")) {
                    showPicker.wrappedValue = true
                }
                .dsFont(.caption2, weight: .semibold)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
        }
    }

    @ViewBuilder
    private var kitchenClosedCard: some View {
        if viewModel.isKitchenClosed {
            GlassCardView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "areaDetail.kitchenClosed.title"))
                        .dsFont(.headline, weight: .bold)
                    Text(String(format: String(localized: "areaDetail.kitchenClosed.message"), viewModel.completedTodayCount, viewModel.dailyBowlTarget))
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(String(localized: "areaDetail.kitchenClosed.helper"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(theme.grid.cardPadding)
            }
        }
    }

    // MARK: - Task List

    // Added 2026-01-14 23:20 GMT
    private var taskListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "areaDetail.tasks.title"))
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            if showTaskExplanation {
                GlassCardView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "areaDetail.tasks.explainer.title"))
                            .dsFont(.headline, weight: .bold)
                        Text(String(localized: "areaDetail.tasks.explainer.message"))
                            .dsFont(.subheadline)
                            .foregroundStyle(.secondary)
                        Button(String(localized: "areaDetail.tasks.explainer.action")) {
                            showTaskExplanation = false
                            taskExplanationShown = true
                        }
                        .buttonStyle(.nativeGlass)
                    }
                    .padding(theme.grid.cardPadding)
                }
            }

            TaskPierogiDropCard(
                tasks: taskDropTasks,
                goldenChancePercent: AppConfigService.shared.verificationGoldenChancePercent
            ) { task in
                withAnimation(theme.motion.listSpring) {
                    completeTask(task, haptic: .success)
                }
            } onToggleTask: { task in
                withAnimation(theme.motion.listSpring) {
                    completeTask(task, haptic: .selection)
                }
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
            if taskExplanationShown == false, taskDropTasks.isEmpty == false {
                showTaskExplanation = true
            }
        }
        .onChange(of: showTaskTapHint) { _, isVisible in
            if isVisible == false {
                taskTapHintShown = true
            }
        }
        .onChange(of: showTaskExplanation) { _, isVisible in
            if isVisible == false {
                taskExplanationShown = true
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
                    cameraSourceControls(showPicker: $showVerificationSourcePicker)
                    Button {
                        beginVerificationFlow(for: bowl)
                    } label: {
                        Label(String(localized: "areaDetail.verify.callout.primary"), systemImage: "checkmark.seal.fill")
                            .dsFont(.headline)
                    }
                    .buttonStyle(.nativeGlassProminent)
                    .padding(.top, 4)
                    Button {
                        takeBasePointsOnly(for: bowl)
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
        VStack(alignment: .trailing, spacing: 6) {
            Button {
                requestCameraCapture()
                hapticFeedback(.medium)
            } label: {
                Label(String(localized: "areaDetail.camera.checkIn"), systemImage: "camera")
                    .dsFont(.headline)
            }
            .buttonStyle(.nativeGlassProminent)
            .disabled(isCameraDisabled)
            .accessibilityLabel(String(localized: "areaDetail.camera.checkIn"))
            .accessibilityHint(cameraDisabledReason ?? "")

            if isCameraDisabled == false {
                cameraSourceControls(showPicker: $showCameraSourcePicker)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            if let reason = cameraDisabledReason {
                Text(reason)
                    .dsFont(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(.trailing, theme.grid.sectionSpacing)
        .padding(.bottom, theme.grid.sectionSpacing)
    }

    private var isCameraDisabled: Bool {
        cameraDisabledReason != nil
    }

    private var cameraDisabledReason: String? {
        if viewModel.isGeneratingDream {
            return String(localized: "areaDetail.camera.disabled.generating")
        }
        if viewModel.isLoading {
            return String(localized: "areaDetail.camera.disabled.loading")
        }
        if isVerificationDecisionPending {
            return String(localized: "areaDetail.camera.disabled.verification")
        }
        if viewModel.isKitchenClosed {
            return String(localized: "areaDetail.camera.disabled.kitchenClosed")
        }
        let flowMode = cameraFlowViewModel.determineMode(for: area)
        if area.inProgressBowl != nil, flowMode != .appendTasks {
            return String(localized: "areaDetail.camera.disabled.finishCurrent")
        }
        return nil
    }

    // MARK: - Verification Flow

    private func checkForVerificationPrompt() {
        guard let bowl = area.latestBowl else { return }
        guard bowl.isCompleted else { return }
        guard bowl.verificationOutcome == .skipped else { return }
        guard bowl.verificationRequestedAt == nil else { return }
        verificationBowl = bowl
        viewModel.markVerificationDecisionPending(for: bowl)
    }

    private var isVerificationDecisionPending: Bool {
        guard let bowl = area.latestBowl else { return false }
        return bowl.isCompleted && bowl.verificationOutcome == .pending
    }

    private func takeBasePointsOnly(for bowl: AreaBowl) {
        viewModel.skipVerification(for: bowl)
        showExitPrompt = true
    }

    private func beginVerificationFlow(for bowl: AreaBowl) {
        verificationBowl = bowl
        verificationTier = viewModel.isGoldenEligible() ? .golden : .blue
        startDefaultVerificationCapture()
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

private enum CameraPermissionTarget {
    case scan
    case verification
}

#Preview {
    NavigationStack {
        AreaDetailView(area: Area.sampleAreas[0], viewModel: AreaViewModel())
    }
    .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self, StreamingCameraConfig.self], inMemory: true)
    .environment(AppDependencies())
}
