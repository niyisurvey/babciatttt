//
//  HabitDetailView.swift
//  WeatherHabitTracker
//
//  Detailed view for a single habit showing statistics, history, and actions.
//  Uses Apple's Liquid Glass design for visual elements.
//

import SwiftUI
import SwiftData

/// Detailed view showing habit information, statistics, and completion history.
/// Provides actions for completing, editing, and managing the habit.
struct HabitDetailView: View {
    
    // MARK: - Properties
    
    /// The habit to display
    let habit: Habit
    
    /// ViewModel for habit operations
    @Bindable var viewModel: HabitViewModel
    
    /// Controls the completion celebration animation
    @State private var showCompletionCelebration = false
    
    /// Note for completion
    @State private var completionNote: String = ""
    
    /// Whether to show the note input
    @State private var showNoteInput = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with icon and status
                headerSection
                
                // Quick complete button
                completeButton
                
                // Statistics cards
                statisticsSection
                
                // Streak calendar
                streakSection
                
                // Recent completions
                recentCompletionsSection
            }
            .padding()
        }
        .background(backgroundGradient)
        .navigationTitle(habit.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.editHabit(habit)
                    } label: {
                        Label("Edit Habit", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        viewModel.deleteHabit(habit)
                    } label: {
                        Label("Delete Habit", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $viewModel.showHabitForm) {
            HabitFormView(viewModel: viewModel, habit: viewModel.editingHabit)
        }
        .alert("Add Note", isPresented: $showNoteInput) {
            TextField("How did it go?", text: $completionNote)
            Button("Cancel", role: .cancel) {
                completionNote = ""
            }
            Button("Complete") {
                viewModel.completeHabit(habit, note: completionNote.isEmpty ? nil : completionNote)
                completionNote = ""
                triggerCelebration()
            }
        } message: {
            Text("Add an optional note about this completion")
        }
        .overlay {
            if showCompletionCelebration {
                celebrationOverlay
            }
        }
    }
    
    // MARK: - Background
    
    /// Gradient background using habit color
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                habit.color.opacity(0.2),
                habit.color.opacity(0.1),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header Section
    
    /// Header with habit icon and current status
    private var headerSection: some View {
        GlassCardView {
            VStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(habit.color.opacity(0.2))
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: habit.iconName)
                        .font(.system(size: 44))
                        .foregroundStyle(habit.color)
                        .symbolEffect(.bounce, value: habit.isCompletedToday)
                }
                
                // Description
                if let description = habit.habitDescription {
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Status badges
                HStack(spacing: 12) {
                    statusBadge(
                        icon: "flame.fill",
                        text: "\(habit.currentStreak) day streak",
                        color: .orange
                    )
                    
                    if habit.notificationsEnabled {
                        statusBadge(
                            icon: "bell.fill",
                            text: "Reminders on",
                            color: .blue
                        )
                    }
                }
            }
            .padding(.vertical, 12)
        }
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
    
    /// Small status badge
    private func statusBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15), in: Capsule())
    }
    
    // MARK: - Complete Button
    
    /// Main completion button
    private var completeButton: some View {
        Button {
            if habit.targetFrequency > 1 {
                showNoteInput = true
            } else {
                viewModel.toggleCompletion(for: habit)
                if !habit.isCompletedToday {
                    triggerCelebration()
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .contentTransition(.symbolEffect(.replace))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.isCompletedToday ? "Completed!" : "Mark Complete")
                        .font(.headline)
                        .contentTransition(.numericText())
                    
                    if habit.targetFrequency > 1 {
                        Text("\(habit.todayCompletionCount)/\(habit.targetFrequency) today")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if habit.isCompletedToday && habit.todayCompletionCount >= habit.targetFrequency {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .symbolEffect(.bounce, value: habit.isCompletedToday)
                }
            }
            .padding()
            .background(
                habit.isCompletedToday 
                    ? habit.color.opacity(0.2) 
                    : Color.primary.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(habit.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.success, trigger: habit.isCompletedToday)
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
    
    // MARK: - Statistics Section
    
    /// Grid of statistics
    private var statisticsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            statisticCard(
                title: "Current Streak",
                value: "\(habit.currentStreak)",
                icon: "flame.fill",
                color: .orange
            )
            
            statisticCard(
                title: "Total Completions",
                value: "\(habit.totalCompletions)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            statisticCard(
                title: "Target/Day",
                value: "\(habit.targetFrequency)",
                icon: "target",
                color: .purple
            )
            
            statisticCard(
                title: "Days Tracked",
                value: "\(daysSinceCreation)",
                icon: "calendar",
                color: .blue
            )
        }
    }
    
    /// Individual statistic card
    private func statisticCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {
        GlassCardView {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Streak Section
    
    /// Weekly streak visualization
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
            
            GlassCardView {
                HStack(spacing: 8) {
                    ForEach(weekDays, id: \.self) { date in
                        VStack(spacing: 8) {
                            Text(dayAbbreviation(for: date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ZStack {
                                Circle()
                                    .fill(isCompleted(on: date) ? habit.color : Color.primary.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                
                                if isCompleted(on: date) {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            Text(dayNumber(for: date))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // MARK: - Recent Completions
    
    /// List of recent completions with notes
    private var recentCompletionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.headline)
            
            if let completions = habit.completions?.sorted(by: { $0.completedAt > $1.completedAt }).prefix(5), !completions.isEmpty {
                GlassCardView {
                    VStack(spacing: 0) {
                        ForEach(Array(completions.enumerated()), id: \.element.id) { index, completion in
                            completionRow(completion)
                            
                            if index < completions.count - 1 {
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                }
            } else {
                GlassCardView {
                    Text("No completions yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                }
            }
        }
    }
    
    /// Single completion row
    private func completionRow(_ completion: HabitCompletion) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(formatDate(completion.completedAt))
                    .font(.body)
                
                if let note = completion.note {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Text(formatTime(completion.completedAt))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Celebration Overlay
    
    /// Celebration animation when completing habit
    private var celebrationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)
                
                Text("Great job!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Keep up the streak!")
                    .foregroundStyle(.secondary)
            }
            .padding(40)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        }
        .transition(.scale.combined(with: .opacity))
        .onTapGesture {
            withAnimation {
                showCompletionCelebration = false
            }
        }
    }
    
    // MARK: - Helper Properties
    
    /// Days since habit was created
    private var daysSinceCreation: Int {
        Calendar.current.dateComponents([.day], from: habit.createdAt, to: Date()).day ?? 0
    }
    
    /// Array of dates for the current week
    private var weekDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - 6, to: today)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Triggers the celebration animation
    private func triggerCelebration() {
        withAnimation(.spring()) {
            showCompletionCelebration = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showCompletionCelebration = false
            }
        }
    }
    
    /// Checks if habit was completed on a specific date
    private func isCompleted(on date: Date) -> Bool {
        guard let completions = habit.completions else { return false }
        let calendar = Calendar.current
        return completions.contains { calendar.isDate($0.completedAt, inSameDayAs: date) }
    }
    
    /// Returns day abbreviation (e.g., "Mon")
    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    /// Returns day number (e.g., "15")
    private func dayNumber(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    /// Formats a date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Formats a time for display
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HabitDetailView(
            habit: Habit.sampleHabits[0],
            viewModel: HabitViewModel()
        )
    }
    .modelContainer(for: Habit.self, inMemory: true)
}
