//
//  DailyProgressCard.swift
//  BabciaTobiasz
//
//  Created 2026-01-15 (Claude Code - Phase 1.1)
//  Displays daily scan progress and Kitchen Closed state
//

import SwiftUI

struct DailyProgressCard: View {
    let progress: Int
    let target: Int
    @Environment(\.dsTheme) private var theme

    private var isTargetMet: Bool {
        progress >= target
    }

    private var progressFraction: Double {
        guard target > 0 else { return 0 }
        return min(Double(progress) / Double(target), 1.0)
    }

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: isTargetMet ? "checkmark.circle.fill" : "target")
                        .foregroundStyle(isTargetMet ? .green : theme.palette.primary)
                        .font(.system(size: theme.grid.iconTitle3))
                        .symbolEffect(.pulse, options: .repeating)

                    Text("Today's Progress")
                        .dsFont(.headline)

                    Spacer()
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(progress)")
                        .font(theme.typography.custom(size: 48, weight: .bold))
                        .contentTransition(.numericText())

                    Text("/")
                        .dsFont(.title2)
                        .foregroundStyle(.secondary)

                    Text("\(target)")
                        .dsFont(.title2, weight: .bold)
                        .foregroundStyle(.secondary)

                    Text("scans")
                        .dsFont(.title3)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }

                ProgressView(value: progressFraction)
                    .tint(isTargetMet ? .green : theme.palette.primary)

                if isTargetMet {
                    HStack {
                        Image(systemName: "moon.zzz.fill")
                            .foregroundStyle(.yellow)
                        Text("Kitchen Closed — Rest well!")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
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

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            DailyProgressCard(progress: 0, target: 1)
            DailyProgressCard(progress: 1, target: 1)
            DailyProgressCard(progress: 2, target: 3)
        }
        .padding()
    }
    .dsTheme(.default)
}
