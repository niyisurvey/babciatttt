//
//  AreaRowView.swift
//  BabciaTobiasz
//
//  Row view for displaying an area in the list.
//

import SwiftUI

/// A row view displaying a single area with its icon, name, and bowl progress.
struct AreaRowView: View {

    // MARK: - Properties

    /// The area to display
    let area: Area
    let milestone: MilestoneDisplay?
    @Environment(\.dsTheme) private var theme

    // MARK: - Body

    var body: some View {
        GlassCardView {
            HStack(spacing: 16) {
                progressIndicator
                areaIcon
                areaInfo
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: theme.grid.iconTiny))
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        let completed = area.activeBowl?.tasks?.filter { $0.isCompleted }.count ?? 0
        let total = area.activeBowl?.tasks?.count ?? 0
        let progress = total > 0 ? Double(completed) / Double(total) : 0

        return ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 3)
                .frame(width: 32, height: 32)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(area.color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(-90))

            Text(total == 0 ? "0" : "\(completed)")
                .dsFont(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Area Icon

    private var areaIcon: some View {
        ZStack {
            Circle()
                .fill(area.color.opacity(0.15))
                .frame(width: 44, height: 44)

            Image(systemName: area.iconName)
                .font(.system(size: theme.grid.iconTitle3))
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
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            HStack(spacing: 8) {
                Text(ageLabel)
                    .dsFont(.caption2)
                    .foregroundStyle(.secondary)

                if let milestone {
                    milestoneBadge(milestone)
                }
            }
        }
    }

    private var ageLabel: String {
        let format = NSLocalizedString("area_age_days", comment: "Area age in days")
        return String.localizedStringWithFormat(format, area.ageInDays)
    }

    private func milestoneBadge(_ milestone: MilestoneDisplay) -> some View {
        HStack(spacing: 4) {
            if let badge = milestone.badgeSystemName {
                Image(systemName: badge)
                    .font(.system(size: theme.grid.iconTiny))
            }
            Text("Day \(milestone.day)")
                .dsFont(.caption2, weight: .bold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(area.color.opacity(0.15), in: Capsule())
        .foregroundStyle(area.color)
    }
}

#Preview {
    VStack(spacing: 12) {
        ForEach(Area.sampleAreas) { area in
            AreaRowView(area: area, milestone: nil)
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
