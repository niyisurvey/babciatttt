// MainTabView.swift
// BabciaTobiasz

import SwiftUI
import SwiftData

/// Root tab navigation with Babcia tab layout
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.appDependencies) private var dependencies
    
    @State private var viewModel = MainTabViewModel()
    @State private var weatherViewModel = WeatherViewModel()
    @State private var areaViewModel = AreaViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Tab("Home", systemImage: "house.fill", value: MainTabViewModel.Tab.home) {
                WeatherView(viewModel: weatherViewModel)
            }
            
            Tab("Areas", systemImage: "square.grid.2x2.fill", value: MainTabViewModel.Tab.areas) {
                AreaListView(viewModel: areaViewModel)
            }

            Tab("Babcia", systemImage: "camera.fill", value: MainTabViewModel.Tab.babcia) {
                BabciaStatusView(viewModel: areaViewModel)
            }

            Tab("Gallery", systemImage: "photo.on.rectangle", value: MainTabViewModel.Tab.gallery) {
                PlaceholderScreen(title: "Gallery", subtitle: "Coming soon")
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
    }
    
    private func setupViewModels() {
        let persistenceService = PersistenceService(modelContext: modelContext)
        
        weatherViewModel.configure(
            weatherService: dependencies.weatherService,
            persistenceService: persistenceService,
            locationService: dependencies.locationService
        )
        
        areaViewModel.configure(
            persistenceService: persistenceService,
            notificationService: dependencies.notificationService
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
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, WeatherData.self, WeatherForecast.self], inMemory: true)
        .environment(AppDependencies())
}
