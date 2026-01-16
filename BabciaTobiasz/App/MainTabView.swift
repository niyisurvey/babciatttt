// MainTabView.swift
// BabciaTobiasz

import SwiftUI
import SwiftData
import Foundation

/// Root tab navigation with Babcia tab layout
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies
    
    @State private var viewModel = MainTabViewModel()
    @State private var homeViewModel: HomeViewModel?
    @State private var areaViewModel = AreaViewModel()

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: MainTabViewModel.Tab.home) {
                if let homeViewModel {
                    HomeView(viewModel: homeViewModel, areaViewModel: areaViewModel)
                } else {
                    ProgressView("Loading...")
                }
            }
            
            Tab("Areas", systemImage: "square.grid.2x2.fill", value: MainTabViewModel.Tab.areas) {
                AreaListView(viewModel: areaViewModel)
            }

            Tab("Babcia", systemImage: "camera.fill", value: MainTabViewModel.Tab.babcia) {
                BabciaStatusView(viewModel: areaViewModel)
            }

            Tab("Gallery", systemImage: "photo.on.rectangle", value: MainTabViewModel.Tab.gallery) {
                NavigationStack {
                    GalleryView(areaViewModel: areaViewModel)
                }
            }
            
            Tab("Settings", systemImage: "gear", value: MainTabViewModel.Tab.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onAppear { setupViewModels() }
        .onChange(of: viewModel.selectedTab) { _, _ in
            hapticFeedback(.selection)
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
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, WeatherData.self, WeatherForecast.self, ReminderConfig.self], inMemory: true)
        .environment(AppDependencies())
}
