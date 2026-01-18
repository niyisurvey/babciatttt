//
//  PatternsSummaryCard.swift
//  BabciaTobiasz
//
//  Created 2026-01-15
//

import SwiftUI

struct PatternsSummaryCard: View {
    let totalCompletions: Int
    let topDayLabel: String
    let topDayCount: Int
    let topHourLabel: String
    let topHourCount: Int

    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(theme.palette.primary)
                        .font(.system(size: theme.grid.iconTitle3))
                        .symbolEffect(.pulse, options: .repeating)

                    Text(String(localized: "home.patterns.title"))
                        .dsFont(.headline)

                    Spacer()

                    Text("\(totalCompletions)")
                        .dsFont(.subheadline, weight: .bold)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 8) {
                    PatternRow(
                        label: String(localized: "home.patterns.topDay"),
                        value: topDayLabel,
                        count: topDayCount
                    )
                    PatternRow(
                        label: String(localized: "home.patterns.topHour"),
                        value: topHourLabel,
                        count: topHourCount
                    )
                }

                Text(String(localized: "home.patterns.cta"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }
}

private struct PatternRow: View {
    let label: String
    let value: String
    let count: Int

    var body: some View {
        HStack {
            Text(label)
                .dsFont(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .dsFont(.subheadline, weight: .bold)

            Text(String(format: String(localized: "home.patterns.count"), count))
                .dsFont(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ScrollView {
        PatternsSummaryCard(
            totalCompletions: 24,
            topDayLabel: "Tue",
            topDayCount: 9,
            topHourLabel: "10:00",
            topHourCount: 6
        )
        .padding()
    }
    .dsTheme(.default)
}
