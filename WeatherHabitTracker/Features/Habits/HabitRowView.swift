//
//  HabitRowView.swift
//  WeatherHabitTracker
//
//  Row view for displaying a habit in the list with completion toggle.
//  Uses Liquid Glass card design with smooth animations.
//

import SwiftUI

/// A row view displaying a single habit with its icon, name, streak, and completion toggle.
/// Designed for use in the habit list with swipe actions and animations.
struct HabitRowView: View {
    
    // MARK: - Properties
    
    /// The habit to display
    let habit: Habit
    
    /// Callback when completion is toggled
    var onToggleCompletion: () -> Void
    
    /// Animation state for the completion checkbox
    @State private var isAnimating = false
    
    // MARK: - Body
    
    var body: some View {
        GlassCardView {
            HStack(spacing: 16) {
                // Completion toggle
                completionButton
                
                // Habit icon
                habitIcon
                
                // Habit info
                habitInfo
                
                Spacer()
                
                // Streak badge
                if habit.currentStreak > 0 {
                    streakBadge
                }
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Completion Button
    
    /// Checkbox button for toggling completion
    private var completionButton: some View {
        Button {
            isAnimating = true
            onToggleCompletion()
            
            // Reset animation state
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = false
            }
        } label: {
            ZStack {
                // Background circle
                Circle()
                    .stroke(habit.color.opacity(0.3), lineWidth: 2)
                    .frame(width: 32, height: 32)
                
                // Filled circle when complete
                if habit.isCompletedToday {
                    Circle()
                        .fill(habit.color)
                        .frame(width: 32, height: 32)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                    
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, value: habit.isCompletedToday)
                }
                
                // Progress ring for multi-target habits
                if habit.targetFrequency > 1 && habit.todayCompletionCount > 0 && habit.todayCompletionCount < habit.targetFrequency {
                    Circle()
                        .trim(from: 0, to: Double(habit.todayCompletionCount) / Double(habit.targetFrequency))
                        .stroke(habit.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 32, height: 32)
                        .rotationEffect(.degrees(-90))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: habit.isCompletedToday)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(habit.isCompletedToday ? "Mark as incomplete" : "Mark as complete")
    }
    
    // MARK: - Habit Icon
    
    /// Icon representing the habit
    private var habitIcon: some View {
        ZStack {
            Circle()
                .fill(habit.color.opacity(0.15))
                .frame(width: 44, height: 44)
            
            Image(systemName: habit.iconName)
                .font(.title3)
                .foregroundStyle(habit.color)
        }
    }
    
    // MARK: - Habit Info
    
    /// Text information about the habit
    private var habitInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(habit.name)
                .font(.headline)
                .strikethrough(habit.isCompletedToday && habit.todayCompletionCount >= habit.targetFrequency, color: .secondary)
                .foregroundStyle(habit.isCompletedToday && habit.todayCompletionCount >= habit.targetFrequency ? .secondary : .primary)
            
            HStack(spacing: 8) {
                // Target info
                if habit.targetFrequency > 1 {
                    Label("\(habit.todayCompletionCount)/\(habit.targetFrequency)", systemImage: "target")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Reminder indicator
                if habit.notificationsEnabled {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                // Description preview
                if let description = habit.habitDescription, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }
        }
    }
    
    // MARK: - Streak Badge
    
    /// Badge showing current streak
    private var streakBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.caption2)
            Text("\(habit.currentStreak)")
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.orange)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.orange.opacity(0.15), in: Capsule())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 12) {
        ForEach(Habit.sampleHabits) { habit in
            HabitRowView(habit: habit) {
                print("Toggle: \(habit.name)")
            }
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
