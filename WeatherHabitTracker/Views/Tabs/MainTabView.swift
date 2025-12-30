//
//  MainTabView.swift
//  WeatherHabitTracker
//
//  The main tab navigation view with Weather and Habits tabs.
//  Uses Apple's modern Liquid Glass design with glassEffect modifiers.
//

import SwiftUI
import SwiftData

/// The root tab view of the application containing Weather and Habit tabs.
/// Implements Apple's Liquid Glass design language for iOS 26+.
struct MainTabView: View {
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Environment(AppDependencies.self) private var dependencies
    
    // MARK: - State
    
    @State private var viewModel = MainTabViewModel()
    @State private var weatherViewModel = WeatherViewModel()
    @State private var habitViewModel = HabitViewModel()
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            // Weather Tab
            Tab("Weather", systemImage: "cloud.sun.fill", value: .weather) {
                WeatherView(viewModel: weatherViewModel)
            }
            
            // Habits Tab
            Tab("Habits", systemImage: "checklist", value: .habits) {
                HabitListView(viewModel: habitViewModel)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onAppear {
            setupViewModels()
        }
    }
    
    // MARK: - Setup
    
    /// Configures view models with dependencies
    private func setupViewModels() {
        let persistenceService = PersistenceService(modelContext: modelContext)
        
        weatherViewModel.configure(
            weatherService: dependencies.weatherService,
            persistenceService: persistenceService
        )
        
        habitViewModel.configure(
            persistenceService: persistenceService,
            notificationService: dependencies.notificationService
        )
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .modelContainer(for: [Habit.self, WeatherData.self, WeatherForecast.self], inMemory: true)
        .environment(AppDependencies())
}
