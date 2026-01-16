//
//  HomeView.swift
//  BabciaTobiasz
//
//  Created 2026-01-15 (Claude Code - Phase 1.1)
//  Home dashboard hub with Pot, Streak, Daily Progress, Shop, Stats
//

import SwiftUI
import SwiftData

/// Home dashboard with overview cards
struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @Bindable var areaViewModel: AreaViewModel
    @State private var showShop = false
    @State private var showGallery = false
    @State private var showAnalytics = false

    var body: some View {
        NavigationStack {
            HomeScreenContent(
                viewModel: viewModel,
                onShopTap: { showShop = true },
                onGalleryTap: { showGallery = true },
                onAnalyticsTap: { showAnalytics = true }
            )
                .navigationTitle("")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.hidden, for: .navigationBar)
                #endif
                .refreshable {
                    hapticFeedback(.medium)
                    await viewModel.fetchDashboardData()
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Home")
                            .dsFont(.title2, weight: .bold)
                            .lineLimit(1)
                    }
                }
                .task {
                    await viewModel.fetchDashboardData()
                }
                .alert("Dashboard Error", isPresented: $viewModel.showError) {
                    Button("OK") { viewModel.dismissError() }
                    Button("Retry") {
                        Task { await viewModel.fetchDashboardData() }
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "An error occurred")
                }
                .navigationDestination(isPresented: $showShop) {
                    FilterShopView(viewModel: areaViewModel)
                }
                .navigationDestination(isPresented: $showGallery) {
                    GalleryView(areaViewModel: areaViewModel)
                }
                .navigationDestination(isPresented: $showAnalytics) {
                    AnalyticsView()
                }
        }
    }
}

// MARK: - Screen Content

private struct HomeScreenContent: View {
    @Bindable var viewModel: HomeViewModel
    let onShopTap: () -> Void
    let onGalleryTap: () -> Void
    let onAnalyticsTap: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            HomeBackgroundView()

            ScrollView(showsIndicators: false) {
                HomeScrollContent(
                    viewModel: viewModel,
                    onShopTap: onShopTap,
                    onGalleryTap: onGalleryTap,
                    onAnalyticsTap: onAnalyticsTap
                )
                    .padding()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Scroll Content

private struct HomeScrollContent: View {
    @Bindable var viewModel: HomeViewModel
    let onShopTap: () -> Void
    let onGalleryTap: () -> Void
    let onAnalyticsTap: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isLoading && viewModel.potBalance == 0 {
                SkeletonLoadingView()
                    .transition(.opacity)
            } else {
                HomeDashboardContent(
                    viewModel: viewModel,
                    onShopTap: onShopTap,
                    onGalleryTap: onGalleryTap,
                    onAnalyticsTap: onAnalyticsTap
                )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(theme.motion.listSpring, value: viewModel.isLoading)
    }
}

// MARK: - Dashboard Content

private struct HomeDashboardContent: View {
    @Bindable var viewModel: HomeViewModel
    let onShopTap: () -> Void
    let onGalleryTap: () -> Void
    let onAnalyticsTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Pot (points balance)
            PotCard(balance: viewModel.potBalance)

            // Streak
            StreakCard(currentStreak: viewModel.currentStreak)

            // Daily Progress
            DailyProgressCard(
                progress: viewModel.dailyProgress,
                target: viewModel.dailyTarget
            )

            // Patterns summary
            Button(action: {
                hapticFeedback(.light)
                onAnalyticsTap()
            }) {
                PatternsSummaryCard(
                    totalCompletions: viewModel.totalCompletions,
                    topDayLabel: viewModel.topDayLabel,
                    topDayCount: viewModel.topDayCount,
                    topHourLabel: viewModel.topHourLabel,
                    topHourCount: viewModel.topHourCount
                )
            }
            .buttonStyle(.plain)

            // Shop (navigate to Sklep)
            ShopCard {
                onShopTap()
            }

            // Stats Progress
            StatsCard(lifetimePierogis: viewModel.lifetimePierogis) {
                // TODO: Navigate to StatsProgressView
                print("Navigate to Stats Progress")
            }

            // Latest Dream (optional)
            if viewModel.latestDreamImageData != nil {
                LatestDreamCard(dreamImageData: viewModel.latestDreamImageData) {
                    onGalleryTap()
                }
            }

            // Educational card (communicates the hook)
            HomeInsightCard()
        }
    }
}

// MARK: - Background

private struct HomeBackgroundView: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        LiquidGlassBackground(style: .default)
    }
}

// MARK: - Insight Card (Educational)

private struct HomeInsightCard: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.system(size: theme.grid.iconTitle3))
                        .symbolEffect(.pulse, options: .repeating)

                    Text("How it works")
                        .dsFont(.headline)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    InsightRow(
                        icon: "camera.fill",
                        text: "Scan creates Dream header + tasks"
                    )
                    InsightRow(
                        icon: "paintpalette.fill",
                        text: "Points unlock filters"
                    )
                    InsightRow(
                        icon: "sparkles",
                        text: "Filters change your Area's Dream header"
                    )
                    InsightRow(
                        icon: "photo.fill",
                        text: "Gallery is where your Dream images live"
                    )
                }
            }
            .padding()
        }
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
}

private struct InsightRow: View {
    let icon: String
    let text: String
    @Environment(\.dsTheme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(theme.palette.primary)
                .font(.system(size: theme.grid.iconSmall))
                .frame(width: 24)

            Text(text)
                .dsFont(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Previews

#Preview {
    let schema = Schema([
        Area.self,
        AreaBowl.self,
        CleaningTask.self,
        TaskCompletionEvent.self,
        Session.self,
        User.self,
        ReminderConfig.self
    ])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let context = container.mainContext
    let user = User(potBalance: 142, lifetimePierogis: 456, currentStreak: 7, dailyTarget: 1)
    context.insert(user)

    let service = HomeDataService(modelContext: context)
    let viewModel = HomeViewModel(homeDataService: service, user: user)
    viewModel.potBalance = 142
    viewModel.currentStreak = 7
    viewModel.dailyProgress = 1
    viewModel.dailyTarget = 1
    viewModel.lifetimePierogis = 456
    viewModel.totalCompletions = 24
    viewModel.topDayLabel = "Tue"
    viewModel.topDayCount = 9
    viewModel.topHourLabel = "10:00"
    viewModel.topHourCount = 6

    return HomeView(
        viewModel: viewModel,
        areaViewModel: AreaViewModel()
    )
        .modelContainer(container)
        .dsTheme(.default)
}
