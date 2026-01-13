// AreaDetailView.swift
// BabciaTobiasz

import SwiftUI
import SwiftData

/// Detail view for an Area's current bowl and tasks.
struct AreaDetailView: View {
    let area: Area
    @Bindable var viewModel: AreaViewModel
    @Environment(\.dsTheme) private var theme

    @State private var requestVerification = false
    @State private var showVerificationSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                if let bowl = area.activeBowl {
                    tasksSection(for: bowl)
                    bowlStatusSection(for: bowl)
                    if area.inProgressBowl == nil {
                        startBowlSection
                    }
                } else {
                    startBowlSection
                }
            }
            .padding()
        }
        .background(backgroundGradient)
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(area.name)
                    .dsFont(.headline, weight: .bold)
                    .lineLimit(1)
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.editArea(area)
                    } label: {
                        Label("Edit Area", systemImage: "pencil")
                    }

                    Divider()

                    Button(role: .destructive) {
                        viewModel.deleteArea(area)
                    } label: {
                        Label("Delete Area", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $viewModel.showAreaForm) {
            AreaFormView(viewModel: viewModel, area: viewModel.editingArea)
        }
        .fullScreenCover(isPresented: $showVerificationSheet) {
            if let bowl = area.activeBowl {
                VerificationDecisionView(
                    isGoldenEligible: viewModel.isGoldenEligible(),
                    onDecision: { decision in
                        handleVerificationDecision(decision, for: bowl)
                        showVerificationSheet = false
                    }
                )
                .interactiveDismissDisabled()
            }
        }
        .onAppear { updateVerificationPresentation() }
        .onChange(of: verificationTrigger) { _, _ in
            updateVerificationPresentation()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: [
                    area.color.opacity(0.15),
                    theme.palette.secondary.opacity(0.1),
                    area.color.opacity(0.1),
                    theme.palette.tertiary.opacity(0.15),
                    area.color.opacity(0.2),
                    theme.palette.primary.opacity(0.1),
                    area.color.opacity(0.1),
                    theme.palette.secondary.opacity(0.15),
                    area.color.opacity(0.15)
                ]
            )
        }
        .ignoresSafeArea()
    }

    private func animatedMeshPoints(for date: Date) -> [SIMD2<Float>] {
        let time = Float(date.timeIntervalSince1970)
        let interval = Float(max(theme.motion.meshAnimationInterval, 0.1))
        let baseSpeed = 1.0 / interval
        let offset = sin(time * (baseSpeed * 0.5)) * 0.2
        let offset2 = cos(time * (baseSpeed * 0.35)) * 0.14
        return [
            [0.0, 0.0], [0.5 + offset2, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5 + offset, 0.5 - offset], [1.0, 0.5],
            [0.0, 1.0], [0.5 - offset2, 1.0], [1.0, 1.0]
        ]
    }

    // MARK: - Header

    private var headerSection: some View {
        GlassCardView {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(area.color.opacity(0.2))
                        .frame(width: 96, height: 96)

                    Image(systemName: area.iconName)
                        .font(.system(size: theme.grid.iconLarge))
                        .foregroundStyle(area.color)
                }

                if let description = area.areaDescription, !description.isEmpty {
                    Text(description)
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Give your area a memorable name")
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let bowl = area.latestBowl {
                    Text("Last bowl started \(formattedDate(bowl.createdAt))")
                        .dsFont(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 12)
        }
    }

    // MARK: - Start Bowl

    private var startBowlSection: some View {
        GlassCardView {
            VStack(spacing: 16) {
                Text("Start a bowl")
                    .dsFont(.headline, weight: .bold)

                Text(viewModel.isKitchenClosed ? "Kitchen Closed. Daily target reached." : "Take a photo to generate today's tasks.")
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Toggle("Request verification", isOn: $requestVerification)
                    .toggleStyle(.switch)

                Button {
                    viewModel.startBowl(for: area, verificationRequested: requestVerification)
                    requestVerification = false
                    hapticFeedback(.medium)
                } label: {
                    Label("Start bowl", systemImage: "camera.fill")
                        .dsFont(.headline)
                }
                .buttonStyle(.nativeGlassProminent)
                .disabled(viewModel.isKitchenClosed)
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Tasks

    private func tasksSection(for bowl: AreaBowl) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tasks (\(bowl.tasks?.count ?? 0))")
                .dsFont(.headline, weight: .bold)

            GlassCardView {
                VStack(spacing: 0) {
                    ForEach(bowl.tasks ?? []) { task in
                        taskRow(task)
                        if task.id != bowl.tasks?.last?.id {
                            Divider().padding(.vertical, 8)
                        }
                    }
                }
            }
        }
    }

    private func taskRow(_ task: CleaningTask) -> some View {
        HStack(spacing: 12) {
            Button {
                viewModel.toggleTaskCompletion(task)
                hapticFeedback(.light)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
                    .dsFont(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .dsFont(.body)
                if let detail = task.detail, !detail.isEmpty {
                    Text(detail)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Bowl Status

    private func bowlStatusSection(for bowl: AreaBowl) -> some View {
        GlassCardView {
            VStack(spacing: 12) {
                if bowl.isCompleted {
                    Text("Bowl complete")
                        .dsFont(.headline, weight: .bold)

                    if bowl.verificationRequested {
                        verificationStatusView(for: bowl)
                    } else {
                        Text("No verification requested.")
                            .dsFont(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    Text("Complete the tasks to finish the bowl.")
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Base points")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(bowl.basePoints)")
                            .dsFont(.headline, weight: .bold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total points")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1f", bowl.totalPoints))
                            .dsFont(.headline, weight: .bold)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func verificationStatusView(for bowl: AreaBowl) -> some View {
        if bowl.isVerificationPending {
            return AnyView(
                Text("Verification required. Choose a tier to continue.")
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            )
        }

        let title: String
        let icon: String
        let color: Color

        switch bowl.verificationOutcome {
        case .passed:
            title = bowl.verificationTier == .golden ? "Golden Verified" : "Blue Verified"
            icon = bowl.verificationTier == .golden ? "sparkles" : "checkmark.seal"
            color = bowl.verificationTier == .golden ? .yellow : .blue
        case .failed:
            title = bowl.verificationTier == .golden ? "Golden Failed" : "Blue Failed"
            icon = "xmark.seal"
            color = .red
        case .pending, .skipped:
            title = "No Verification"
            icon = "minus.circle"
            color = .secondary
        }

        return AnyView(
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .dsFont(.headline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(color.opacity(0.15), in: Capsule())
        )
    }

    // MARK: - Helpers

    private var verificationTrigger: String {
        guard let bowl = area.activeBowl else { return "none" }
        return "\(bowl.id.uuidString)-\(bowl.isCompleted)-\(bowl.verificationOutcomeRaw)"
    }

    private func updateVerificationPresentation() {
        guard let bowl = area.activeBowl else { return }
        if bowl.isCompleted && bowl.isVerificationPending {
            showVerificationSheet = true
        }
    }

    private func handleVerificationDecision(_ decision: VerificationDecisionView.Decision, for bowl: AreaBowl) {
        switch decision {
        case .none:
            let tier: BowlVerificationTier = viewModel.isGoldenEligible() ? .golden : .blue
            viewModel.finalizeVerification(for: bowl, tier: tier, outcome: .failed)
        case .blue:
            viewModel.finalizeVerification(for: bowl, tier: .blue, outcome: .passed)
        case .golden:
            viewModel.finalizeVerification(for: bowl, tier: .golden, outcome: .passed)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

private struct VerificationDecisionView: View {
    enum Decision {
        case none
        case blue
        case golden
    }

    let isGoldenEligible: Bool
    let onDecision: (Decision) -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .areas)

            GlassCardView {
                VStack(spacing: 20) {
                    Text("Verification")
                        .dsFont(.title2, weight: .bold)

                    Text("Pick the tier Babcia gives this bowl.")
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        Button {
                            onDecision(.none)
                        } label: {
                            Text("No")
                                .dsFont(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.nativeGlass)

                        Button {
                            onDecision(.blue)
                        } label: {
                            Text("Blue")
                                .dsFont(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.nativeGlassProminent)

                        Button {
                            onDecision(.golden)
                        } label: {
                            Text("Golden")
                                .dsFont(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.nativeGlassProminent)
                        .disabled(!isGoldenEligible)

                        if !isGoldenEligible {
                            Text("Golden unlocks when you need a boost or haven't verified in a week.")
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        AreaDetailView(area: Area.sampleAreas[0], viewModel: AreaViewModel())
    }
    .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self], inMemory: true)
}
