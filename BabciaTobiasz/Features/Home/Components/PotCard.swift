//
//  PotCard.swift
//  BabciaTobiasz
//
//  Created 2026-01-15 (Claude Code - Phase 1.1)
//  Displays current Pot (points balance)
//

import SwiftUI

struct PotCard: View {
    let balance: Int
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(theme.palette.primary)
                        .font(.system(size: theme.grid.iconTitle3))
                        .symbolEffect(.pulse, options: .repeating)

                    Text("Your Pot")
                        .dsFont(.headline)

                    Spacer()
                }

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(balance)")
                        .font(theme.typography.custom(size: 56, weight: .bold))
                        .contentTransition(.numericText())

                    Text("pierogis")
                        .dsFont(.title3)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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
        PotCard(balance: 142)
            .padding()
    }
    .dsTheme(.default)
}
