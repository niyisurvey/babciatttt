// AreaListView.swift
// BabciaTobiasz

import SwiftUI
import SwiftData
import OSLog

/// Main area list with management and statistics
struct AreaListView: View {
    @Bindable var viewModel: AreaViewModel
    @AppStorage("primaryPersonaRaw") private var primaryPersonaRaw: String = BabciaPersona.classic.rawValue
    @AppStorage("needsFirstArea") private var needsFirstArea = false
    @State private var showStatsTooltip = false
    @State private var headerProgress: CGFloat = 0
    @State private var showVictoryHero = false
    @Environment(\.dsTheme) private var theme
    private let logger = Logger(subsystem: "com.babcia.tobiasz", category: "navigation")

    private var heroImageName: String {
        let persona = BabciaPersona(rawValue: primaryPersonaRaw) ?? .classic
        if viewModel.isInactiveForHero {
            return persona.portraitSadImageName
        }
        return persona.fullBodyImageName(for: heroPose)
    }

    private var heroPose: BabciaPose {
        if viewModel.isInactiveForHero {
            return .sadDisappointed
        }
        if showVictoryHero {
            return .victory
        }
        return .happy
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                backgroundGradient
                
                if viewModel.isLoading {
                    AreaSkeletonLoadingView()
                        .transition(.opacity)
                } else {
                    areasScrollContent
                        .transition(.opacity)
                }
            }
            .animation(theme.motion.listSpring, value: viewModel.areas.isEmpty)
            .navigationTitle("")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
            .toolbar { toolbarContent }
            .sheet(isPresented: $viewModel.showAreaForm) {
                AreaFormView(viewModel: viewModel, area: viewModel.editingArea)
            }
            .safeAreaInset(edge: .bottom) {
                areasSearchBar
            }
            .onAppear {
                viewModel.loadAreas()
                handleFirstAreaIfNeeded()
            }
            .onChange(of: viewModel.totalCompletions) { _, _ in
                guard viewModel.isInactiveForHero == false else { return }
                showVictoryHero = true
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(2))
                    showVictoryHero = false
                }
            }
            .alert(String(localized: "common.error.title"), isPresented: $viewModel.showError) {
                Button(String(localized: "common.ok")) { viewModel.dismissError() }
            } message: {
                Text(viewModel.errorMessage ?? String(localized: "common.error.fallback"))
            }
            // Keep destination on the same NavigationStack to avoid SwiftUI fallback screens.
            .navigationDestination(for: AreaRoute.self) { route in
                switch route {
                case .detail(let areaId):
                    if let area = viewModel.area(for: areaId) {
                        AreaDetailView(area: area, viewModel: viewModel)
                    } else {
                        ErrorView(
                            title: String(localized: "areas.detail.unavailable.title"),
                            message: String(format: String(localized: "areas.detail.unavailable.message"), areaId.uuidString),
                            iconName: "exclamationmark.triangle.fill",
                            iconColor: theme.palette.warning,
                            retryAction: { viewModel.loadAreas() }
                        )
                        .onAppear {
                            logger.error("Area route missing area for id \(areaId, privacy: .public)")
                        }
                    }
                }
            }
        }
    }

    private func handleFirstAreaIfNeeded() {
        guard needsFirstArea else { return }
        guard viewModel.areas.isEmpty else {
            needsFirstArea = false
            return
        }
        DispatchQueue.main.async {
            viewModel.addNewArea()
        }
    }
    
    // MARK: - Background
    
    private var backgroundGradient: some View {
        LiquidGlassBackground(style: .areas)
    }
    
    // MARK: - Content
    
    private var areasScrollContent: some View {
        ScalingHeaderScrollView(
            maxHeight: 260,
            minHeight: 120,
            snapMode: .none,
            progress: $headerProgress
        ) { progress in
            AreasHeroHeader(
                imageName: heroImageName,
                message: heroMessage,
                progress: progress
            )
        } content: {
            VStack(spacing: 20) {
                if viewModel.areas.isEmpty {
                    emptyStateView
                } else {
                    statisticsCard
                    filterPicker
                    areasList
                }
            }
            .padding()
        }
    }
    
    private var areasSearchBar: some View {
        GlassCardView {
            HStack(spacing: theme.grid.listSpacing) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: theme.grid.iconSmall))
                    .foregroundStyle(.secondary)
                
                TextField(
                    "",
                    text: $viewModel.searchText,
                    prompt: Text(String(localized: "areas.search.placeholder"))
                        .font(theme.typography.font(.body, weight: .regular, italic: false))
                        .foregroundStyle(.secondary)
                )
                .dsFont(.body)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            }
            .padding(.vertical, 10)
        }
        .padding(.horizontal, theme.grid.cardPadding)
        .padding(.bottom, 8)
    }
    
    // MARK: - Statistics
    
    private var statisticsCard: some View {
        GlassCardView {
            VStack(spacing: 16) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 12)
                        .frame(width: theme.grid.ringSize, height: theme.grid.ringSize)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.todayCompletionPercentage)
                        .stroke(
                            LinearGradient(colors: theme.gradients.areasProgress, startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: theme.grid.ringSize, height: theme.grid.ringSize)
                        .rotationEffect(.degrees(-90))
                        .animation(theme.motion.statsSpring, value: viewModel.todayCompletionPercentage)
                    
                    VStack(spacing: 2) {
                        Text("\(viewModel.completedTodayCount)/\(viewModel.dailyBowlTarget)")
                            .dsFont(.title2, weight: .bold)
                            .contentTransition(.numericText())
                        Text(String(localized: "areas.stats.today"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack(spacing: 30) {
                    statisticItem(
                        icon: "flame.fill",
                        value: "\(viewModel.bestStreak)",
                        label: String(localized: "areas.stats.streak"),
                        color: .orange
                    )
                    
                    Divider().frame(height: 40)
                    
                    statisticItem(
                        icon: "checkmark.circle.fill",
                        value: "\(viewModel.totalCompletions)",
                        label: String(localized: "areas.stats.totalDone"),
                        color: .green
                    )
                }

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "areas.stats.dailyTarget"))
                            .dsFont(.headline, weight: .bold)
                        Text(viewModel.isKitchenClosed
                             ? String(localized: "areas.stats.kitchenClosed")
                             : String(localized: "areas.stats.kitchenOpen"))
                            .dsFont(.caption)
                            .foregroundStyle(viewModel.isKitchenClosed ? .red : .secondary)
                    }

                    Spacer()

                    Stepper(value: $viewModel.dailyBowlTarget, in: 1...10) {
                        Text("\(viewModel.dailyBowlTarget)")
                            .dsFont(.headline, weight: .bold)
                            .frame(minWidth: 28, alignment: .trailing)
                    }
                    .labelsHidden()
                }
            }
            .padding(.vertical, 12)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation(theme.motion.pressSpring) {
                    showStatsTooltip.toggle()
                }
                hapticFeedback(.light)
            } label: {
                Image(systemName: "info.circle")
                    .font(.system(size: theme.grid.iconTiny))
                    .foregroundStyle(.secondary)
            }
            .padding(12)
        }
        .overlay {
            if showStatsTooltip {
                FeatureTooltip(
                    title: String(localized: "areas.stats.tooltip.title"),
                    description: String(localized: "areas.stats.tooltip.message"),
                    icon: "chart.bar.fill",
                    isVisible: $showStatsTooltip
                )
                .transition(.scale.combined(with: .opacity))
                .offset(y: -120)
            }
        }
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
    
    private func statisticItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(value)
            }
            .dsFont(.headline, weight: .bold)
            
            Text(label)
                .dsFont(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Filter
    
    private var filterPicker: some View {
        Picker(String(localized: "areas.filter.title"), selection: $viewModel.filterOption) {
            ForEach(AreaViewModel.FilterOption.allCases) { option in
                Text(option.localizedLabel).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.filterOption) { _, _ in
            hapticFeedback(.selection)
        }
    }
    
    // MARK: - Areas List
    
    private var areasList: some View {
        let items = Array(viewModel.filteredAreas.enumerated())
        let overlap = theme.grid.listSpacing * 0.4
        return LazyVStack(spacing: -overlap) {
            ForEach(items, id: \.element.id) { index, area in
                let stackScale = 1 - min(Double(index) * 0.02, 0.08)
                Button {
                    viewModel.openArea(area.id)
                    hapticFeedback(.selection)
                } label: {
                    AreaRowView(area: area, milestone: viewModel.milestone(for: area))
                }
                .buttonStyle(.plain)
                .contextMenu { areaContextMenu(for: area) }
                .scaleEffect(stackScale)
                .offset(y: CGFloat(index) * overlap)
                .zIndex(Double(viewModel.filteredAreas.count - index))
                .scrollTransition { content, phase in
                    content
                        .opacity(phase.isIdentity ? 1 : 0.5)
                        .scaleEffect(phase.isIdentity ? 1 : 0.95)
                        .blur(radius: phase.isIdentity ? 0 : 2)
                }
            }
        }
        .sensoryFeedback(.success, trigger: viewModel.totalCompletions)
    }
    
    private func areaContextMenu(for area: Area) -> some View {
        Group {
            Button {
                viewModel.editArea(area)
                hapticFeedback(.light)
            } label: {
                Label(String(localized: "areas.menu.edit"), systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
                viewModel.deleteArea(area)
                hapticFeedback(.warning)
            } label: {
                Label(String(localized: "areas.menu.delete"), systemImage: "trash")
            }
        }
    }

    private var heroMessage: String? {
        viewModel.isInactiveForHero ? String(localized: "areas.hero.inactive") : nil
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        GlassCardView {
            VStack(spacing: 24) {
                Image(systemName: "checklist")
                    .font(.system(size: theme.grid.iconXXL))
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 8) {
                    Text(String(localized: "areas.empty.title"))
                        .dsFont(.title2, weight: .bold)
                    
                    Text(String(localized: "areas.empty.message"))
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    viewModel.addNewArea()
                    hapticFeedback(.medium)
                } label: {
                    Label(String(localized: "areas.empty.action"), systemImage: "plus.circle.fill")
                        .dsFont(.headline)
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .padding()
        }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(String(localized: "areas.toolbar.title"))
                .dsFont(.title2, weight: .bold)
                .lineLimit(1)
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.addNewArea()
                hapticFeedback(.medium)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: theme.grid.iconSmall))
            }
            .accessibilityLabel(String(localized: "areas.toolbar.add.accessibility"))
        }
    }
}

private struct AreasHeroHeader: View {
    let imageName: String
    let message: String?
    let progress: CGFloat
    @Environment(\.dsTheme) private var theme

    var body: some View {
        let fade = max(CGFloat.zero, CGFloat(1) - progress * CGFloat(1.2))
        ZStack(alignment: .bottom) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, theme.grid.sectionSpacing)
                .opacity(fade)
            if let message {
                Text(message)
                    .dsFont(.caption, weight: .bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, theme.grid.cardPadding)
                    .padding(.vertical, theme.grid.cardPaddingTight)
                    .background(.ultraThinMaterial, in: Capsule())
                    .padding(.bottom, theme.grid.cardPadding)
                    .opacity(fade)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeOut(duration: 0.2), value: progress)
    }
}

#Preview {
    AreaListView(viewModel: AreaViewModel())
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self, StreamingCameraConfig.self], inMemory: true)
        .environment(AppDependencies())
}
