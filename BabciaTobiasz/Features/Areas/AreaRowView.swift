//
//  AreaRowView.swift
//  BabciaTobiasz
//
//  Row view for displaying an area in the list.
//

import SwiftUI
import SwiftData

/// A row view displaying a single area with its icon, name, and bowl progress.
struct AreaRowView: View {

    // MARK: - Properties

    /// The area to display
    let area: Area
    let milestone: MilestoneDisplay?
    @Query private var reminderConfigs: [ReminderConfig]
    @Environment(\.dsTheme) private var theme

    // MARK: - Body

    init(area: Area, milestone: MilestoneDisplay?) {
        self.area = area
        self.milestone = milestone
        let areaId = area.id
        _reminderConfigs = Query(filter: #Predicate<ReminderConfig> { $0.areaId == areaId })
    }

    var body: some View {
        GlassCardView {
            HStack(spacing: theme.grid.cardPadding) {
                progressIndicator
                areaIcon
                areaInfo
                Spacer()
                Image(systemName: "chevron.right")
                    .font(theme.typography.font(.caption2))
                    .foregroundStyle(theme.palette.textSecondary).opacity(theme.glass.glowOpacityLow)
            }
            .padding(.vertical, theme.grid.cardPaddingTight / 3)
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        let completed = area.activeBowl?.tasks?.filter { $0.isCompleted }.count ?? 0
        let total = area.activeBowl?.tasks?.count ?? 0
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return ZStack {
            Circle()
                .stroke(theme.palette.neutral.opacity(theme.elevation.shimmerOpacity), lineWidth: 3)
                .frame(width: theme.grid.listSpacing * 2.6, height: theme.grid.listSpacing * 2.6)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(area.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: theme.grid.listSpacing * 2.6, height: theme.grid.listSpacing * 2.6)
                .rotationEffect(.degrees(-90))

            Text(total == 0 ? "0" : "\(completed)")
                .dsFont(.caption2)
                .foregroundStyle(theme.palette.textSecondary)
        }
    }

    // MARK: - Area Icon

    private var areaIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.shape.controlCornerRadius, style: .continuous)
                .fill(area.color.opacity(theme.elevation.shimmerOpacity / 2))
                .frame(width: theme.grid.iconLarge, height: theme.grid.iconLarge)

            Image(systemName: area.iconName)
                .font(theme.typography.font(.title3))
                .foregroundStyle(area.color)
        }
    }

    // MARK: - Area Info

    private var areaInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(area.name)
                .dsFont(.headline)

            if let description = area.areaDescription, !description.isEmpty {
                Text(description)
                    .dsFont(.caption)
                    .foregroundStyle(theme.palette.textSecondary).opacity(theme.glass.glowOpacityLow)
                    .lineLimit(1)
            }

            statusBadge

            reminderPreviewRow

            HStack(spacing: theme.grid.listSpacing) {
                Text(ageLabel)
                    .dsFont(.caption2)
                    .foregroundStyle(theme.palette.textSecondary)

                if let milestone {
                    milestoneBadge(milestone)
                }
            }
        }
    }

    private var ageLabel: String {
        String(format: String(localized: "areaRow.age.days"), area.ageInDays)
    }

    private func milestoneBadge(_ milestone: MilestoneDisplay) -> some View {
        HStack(spacing: theme.grid.cardPaddingTight / 3) {
            if let badge = milestone.badgeSystemName {
                Image(systemName: badge)
                    .font(theme.typography.font(.caption2))
            }
            Text(String(format: String(localized: "areaRow.milestone.day"), milestone.day))
                .dsFont(.caption2, weight: .bold)
        }
        .padding(.horizontal, theme.grid.cardPaddingTight / 1.5)
        .padding(.vertical, theme.grid.cardPaddingTight / 3)
        .background(area.color.opacity(theme.elevation.shimmerOpacity / 2), in: Capsule())
        .foregroundStyle(area.color)
    }

    private var reminderPreviewRow: some View {
        HStack(spacing: theme.grid.cardPaddingTight / 2) {
            Image(systemName: "bell.badge")
                .font(theme.typography.font(.caption2))
                .foregroundStyle(theme.palette.textSecondary)
            Text(String(localized: "reminders.preview.label"))
                .dsFont(.caption2)
                .foregroundStyle(theme.palette.textSecondary)
            Text(reminderTimesText)
                .dsFont(.caption2, weight: .bold)
                .foregroundStyle(theme.palette.textSecondary)
                .lineLimit(1)
        }
    }

    private var reminderTimesText: String {
        guard let config = reminderConfigs.first,
              config.isEnabled,
              !config.activeSlotTimes.isEmpty else {
            return String(localized: "reminders.preview.off")
        }

        return config.activeSlotTimes
            .sorted()
            .map { $0.formatted(date: .omitted, time: .shortened) }
            .joined(separator: " • ")
    }

    @ViewBuilder
    private var statusBadge: some View {
        if let status = statusState {
            HStack(spacing: theme.grid.cardPaddingTight / 2) {
                Circle()
                    .fill(statusColor(status))
                    .frame(width: theme.grid.iconTiny / 2, height: theme.grid.iconTiny / 2)
                Text(status.label)
                    .dsFont(.caption2, weight: .bold)
                    .foregroundStyle(statusColor(status))
            }
            .padding(.horizontal, theme.grid.cardPaddingTight / 1.5)
            .padding(.vertical, theme.grid.cardPaddingTight / 3)
            .background(statusColor(status).opacity(theme.glass.glowOpacityLow), in: Capsule())
        }
    }

    private func statusColor(_ status: AreaRowStatus) -> Color {
        switch status {
        case .needsScan: return theme.palette.warning
        case .inProgress: return theme.palette.primary
        case .doneToday: return theme.palette.success
        case .verificationPending: return theme.palette.secondary
        }
    }

    private var statusState: AreaRowStatus? {
        if let bowl = area.latestBowl, bowl.isVerificationPending {
            return .verificationPending
        }
        if isCompletedToday {
            return .doneToday
        }
        if area.inProgressBowl != nil {
            return .inProgress
        }
        if area.latestBowl == nil {
            return .needsScan
        }
        return nil
    }

    private var isCompletedToday: Bool {
        guard let completedAt = area.latestBowl?.completedAt else { return false }
        return Calendar.current.isDateInToday(completedAt)
    }
}

private enum AreaRowStatus {
    case needsScan
    case inProgress
    case doneToday
    case verificationPending

    var label: String {
        switch self {
        case .needsScan:
            return String(localized: "areaRow.status.needsScan")
        case .inProgress:
            return String(localized: "areaRow.status.inProgress")
        case .doneToday:
            return String(localized: "areaRow.status.doneToday")
        case .verificationPending:
            return String(localized: "areaRow.status.verification")
        }
    }

    var color: Color {
        .gray // Placeholder, use statusColor in view
    }
}

#Preview {
    let theme = DesignSystemTheme.default
    VStack(spacing: 12) {
        ForEach(Area.sampleAreas) { area in
            AreaRowView(area: area, milestone: nil)
        }
    }
    .padding()
    .background(theme.palette.neutral.opacity(theme.glass.glowOpacityLow / 2))
    .modelContainer(for: [
        Area.self,
        AreaBowl.self,
        CleaningTask.self,
        TaskCompletionEvent.self,
        Session.self,
        User.self,
        ReminderConfig.self,
        StreamingCameraConfig.self
    ], inMemory: true)
}
