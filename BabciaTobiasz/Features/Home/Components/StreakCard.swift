//
//  StreakCard.swift
//  BabciaTobiasz
//
//  Created 2026-01-15 (Claude Code - Phase 1.1)
//  Displays current cleaning streak
//

import SwiftUI

struct StreakCard: View {
    let currentStreak: Int
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: theme.grid.iconTitle3))
                        .symbolEffect(.pulse, options: .repeating)

                    Text("Streak")
                        .dsFont(.headline)

                    Spacer()
                }

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(currentStreak)")
                        .font(theme.typography.custom(size: 48, weight: .bold))
                        .contentTransition(.numericText())

                    Text(currentStreak == 1 ? "day" : "days")
                        .dsFont(.title3)
                        .foregroundStyle(.secondary)
                }

                Text("Keep going! Scan once per day to maintain your streak.")
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
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
        StreakCard(currentStreak: 7)
            .padding()
    }
    .dsTheme(.default)
}
