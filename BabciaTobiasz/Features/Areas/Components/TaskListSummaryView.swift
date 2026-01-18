//
//  TaskListSummaryView.swift
//  BabciaTobiasz
//

import SwiftUI

struct TaskListSummaryView: View {
    let tasks: [CleaningTask]
    let onToggleTask: (CleaningTask) -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.grid.cardPaddingTight) {
            ForEach(Array(tasks.prefix(5)), id: \.id) { task in
                Button {
                    onToggleTask(task)
                    hapticFeedback(.selection)
                } label: {
                    TaskListSummaryRow(task: task)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TaskListSummaryRow: View {
    let task: CleaningTask
    @Environment(\.dsTheme) private var theme
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: theme.grid.cardPaddingTight) {
            Circle()
                .fill(task.isCompleted ? theme.palette.secondary : theme.palette.warmAccent)
                .frame(width: theme.grid.iconTiny / 2, height: theme.grid.iconTiny / 2)
                .scaleEffect(task.isCompleted ? 1 : (isPulsing ? 1.2 : 0.9))
            Text(task.title)
                .dsFont(.subheadline)
                .foregroundStyle(task.isCompleted ? .secondary : .primary)
                .strikethrough(task.isCompleted, color: theme.palette.secondary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
        .onAppear {
            guard task.isCompleted == false else { return }
            withAnimation(theme.motion.fadeStandard.repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

#Preview {
    TaskListSummaryView(tasks: [
        CleaningTask(title: "Clear visible surfaces"),
        CleaningTask(title: "Put loose items away"),
        CleaningTask(title: "Wipe one surface")
    ], onToggleTask: { _ in })
    .padding()
    .dsTheme(.default)
}
