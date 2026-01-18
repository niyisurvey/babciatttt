// MainTabView.swift
// BabciaTobiasz

import SwiftUI
import SwiftData
import Foundation

/// Root tab navigation with Babcia tab layout
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies
    @AppStorage(AppIntentRoute.storageKey) private var appIntentRoute: String = AppIntentRoute.none.rawValue
    
    @State private var viewModel = MainTabViewModel()
    @State private var homeViewModel: HomeViewModel?
    @State private var areaViewModel = AreaViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab(String(localized: "mainTab.home.label"), systemImage: "house.fill", value: MainTabViewModel.Tab.home) {
                if let homeViewModel {
                    HomeView(viewModel: homeViewModel, areaViewModel: areaViewModel)
                } else {
                    ProgressView(String(localized: "mainTab.loading"))
                }
            }
            
            Tab(String(localized: "mainTab.areas.label"), systemImage: "square.grid.2x2.fill", value: MainTabViewModel.Tab.areas) {
                AreaListView(viewModel: areaViewModel)
            }

            Tab(String(localized: "mainTab.babcia.label"), systemImage: "camera.fill", value: MainTabViewModel.Tab.babcia) {
                MicroTidyView {
                    viewModel.selectedTab = .areas
                }
            }

            Tab(String(localized: "mainTab.gallery.label"), systemImage: "photo.on.rectangle", value: MainTabViewModel.Tab.gallery) {
                NavigationStack {
                    GalleryView(areaViewModel: areaViewModel)
                }
            }
            
            Tab(String(localized: "mainTab.settings.label"), systemImage: "gear", value: MainTabViewModel.Tab.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onAppear {
            setupViewModels()
            handleIntentRoute(appIntentRoute)
        }
        .onChange(of: viewModel.selectedTab) { _, _ in
            hapticFeedback(.selection)
        }
        .onChange(of: appIntentRoute) { _, newValue in
            handleIntentRoute(newValue)
        }
        .onReceive(NotificationCenter.default.publisher(for: .areaReminderTapped)) { notification in
            if let areaId = notification.userInfo?["areaId"] as? UUID {
                viewModel.selectedTab = .areas
                areaViewModel.openAreaFromReminder(areaId)
            }
        }
    }
    
    private func setupViewModels() {
        let persistenceService = PersistenceService(modelContext: modelContext)
        let potService = PotService(modelContext: modelContext)
        let homeDataService = HomeDataService(modelContext: modelContext)
        var currentUser: User?

        do {
            currentUser = try persistenceService.fetchOrCreateUser()
        } catch {
            areaViewModel.errorMessage = error.localizedDescription
            areaViewModel.showError = true
        }

        // Wire HomeViewModel with dependencies
        if let currentUser {
            homeViewModel = HomeViewModel(homeDataService: homeDataService, user: currentUser)
        }

        areaViewModel.configure(
            persistenceService: persistenceService,
            reminderScheduler: dependencies.services.reminders,
            // Added 2026-01-14 22:55 GMT
            scanPipelineService: dependencies.scanPipelineService,
            potService: potService,
            currentUser: currentUser,
            progressionService: dependencies.services.progression
        )
    }

    private func handleIntentRoute(_ routeValue: String) {
        guard let route = AppIntentRoute(rawValue: routeValue), route != .none else { return }
        switch route {
        case .home:
            viewModel.selectedTab = .home
        case .areas:
            viewModel.selectedTab = .areas
        case .babcia, .startScan:
            viewModel.selectedTab = .babcia
        case .gallery:
            viewModel.selectedTab = .gallery
        case .settings:
            viewModel.selectedTab = .settings
        case .none:
            break
        }
        appIntentRoute = AppIntentRoute.none.rawValue
    }
}

private struct PlaceholderScreen: View {
    let title: String
    let subtitle: String
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            VStack(spacing: theme.grid.sectionSpacing) {
                Text(title)
                    .dsFont(.title, weight: .bold)
                Text(subtitle)
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, theme.grid.cardPadding)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self], inMemory: true)
        .environment(AppDependencies())
}
