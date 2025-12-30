//
//  HabitListView.swift
//  WeatherHabitTracker
//
//  The main habit list view displaying all habits with filtering and management options.
//  Uses Apple's Liquid Glass design and SwiftUI Lists.
//

import SwiftUI
import SwiftData

/// The habits tab view displaying the list of habits with management capabilities.
/// Features search, filtering, and quick completion actions.
struct HabitListView: View {
    
    // MARK: - Properties
    
    @Bindable var viewModel: HabitViewModel
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                // Content
                if viewModel.habits.isEmpty && !viewModel.isLoading {
                    emptyStateView
                } else {
                    habitListContent
                }
            }
            .navigationTitle("Habits")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .searchable(text: $viewModel.searchText, prompt: "Search habits")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $viewModel.showHabitForm) {
                HabitFormView(
                    viewModel: viewModel,
                    habit: viewModel.editingHabit
                )
            }
            .onAppear {
                viewModel.loadHabits()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
        }
    }
    
    // MARK: - Background
    
    /// Gradient background for the habit list using MeshGradient
    private var backgroundGradient: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .green.opacity(0.25), .teal.opacity(0.2), .cyan.opacity(0.25),
                .mint.opacity(0.15), .green.opacity(0.2), .teal.opacity(0.2),
                .teal.opacity(0.2), .mint.opacity(0.15), .green.opacity(0.25)
            ]
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Habit List Content
    
    /// Main list content with statistics and habits
    private var habitListContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Statistics Card
                statisticsCard
                
                // Filter Picker
                filterPicker
                
                // Habit List
                habitsList
            }
            .padding()
        }
    }
    
    // MARK: - Statistics Card
    
    /// Overview statistics card with Liquid Glass effect
    private var statisticsCard: some View {
        GlassCardView {
            VStack(spacing: 16) {
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(.quaternary, lineWidth: 12)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: viewModel.todayCompletionPercentage)
                        .stroke(
                            LinearGradient(
                                colors: [.green, .teal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 0.5), value: viewModel.todayCompletionPercentage)
                    
                    VStack(spacing: 2) {
                        Text("\(viewModel.completedTodayCount)/\(viewModel.totalHabitsCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Statistics Grid
                HStack(spacing: 30) {
                    statisticItem(
                        icon: "flame.fill",
                        value: "\(viewModel.bestStreak)",
                        label: "Best Streak",
                        color: .orange
                    )
                    
                    Divider()
                        .frame(height: 40)
                    
                    statisticItem(
                        icon: "checkmark.circle.fill",
                        value: "\(viewModel.totalCompletions)",
                        label: "Total Done",
                        color: .green
                    )
                }
            }
            .padding(.vertical, 12)
        }
    }
    
    /// Individual statistic item
    private func statisticItem(
        icon: String,
        value: String,
        label: String,
        color: Color
    ) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(value)
                    .fontWeight(.bold)
            }
            .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Filter Picker
    
    /// Filter segmented control
    private var filterPicker: some View {
        Picker("Filter", selection: $viewModel.filterOption) {
            ForEach(HabitViewModel.FilterOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
    
    // MARK: - Habits List
    
    /// List of habit rows
    private var habitsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.filteredHabits) { habit in
                NavigationLink(destination: HabitDetailView(habit: habit, viewModel: viewModel)) {
                    HabitRowView(
                        habit: habit,
                        onToggleCompletion: {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.toggleCompletion(for: habit)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
                .contextMenu {
                    habitContextMenu(for: habit)
                }
            }
        }
    }
    
    /// Context menu actions for a habit
    private func habitContextMenu(for habit: Habit) -> some View {
        Group {
            Button {
                viewModel.toggleCompletion(for: habit)
            } label: {
                Label(
                    habit.isCompletedToday ? "Mark Incomplete" : "Mark Complete",
                    systemImage: habit.isCompletedToday ? "xmark.circle" : "checkmark.circle"
                )
            }
            
            Button {
                viewModel.editHabit(habit)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive) {
                viewModel.deleteHabit(habit)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    // MARK: - Empty State
    
    /// Empty state view when no habits exist
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checklist")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Habits Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start building good habits by adding your first one!")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                viewModel.addNewHabit()
            } label: {
                Label("Add Your First Habit", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .padding()
    }
    
    // MARK: - Toolbar
    
    /// Toolbar content
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                viewModel.addNewHabit()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .accessibilityLabel("Add new habit")
        }
    }
}

// MARK: - Preview

#Preview {
    HabitListView(viewModel: HabitViewModel())
        .modelContainer(for: Habit.self, inMemory: true)
        .environment(AppDependencies())
}
