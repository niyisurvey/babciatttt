//
//  ShopCard.swift
//  BabciaTobiasz
//
//  Created 2026-01-15 (Claude Code - Phase 1.1)
//  Navigate to Sklep (Filter Shop)
//

import SwiftUI

struct ShopCard: View {
    let onTap: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            onTap()
        }) {
            GlassCardView {
                HStack(spacing: 16) {
                    Image(systemName: "paintpalette.fill")
                        .foregroundStyle(theme.palette.secondary)
                        .font(.system(size: theme.grid.iconLarge))
                        .symbolEffect(.pulse, options: .repeating)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "home.shop.title"))
                            .dsFont(.headline)

                        Text(String(localized: "home.shop.subtitle"))
                            .dsFont(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                        .font(.system(size: theme.grid.iconSmall))
                }
                .padding()
            }
        }
        .buttonStyle(.plain)
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
        ShopCard(onTap: {})
            .padding()
    }
    .dsTheme(.default)
}
