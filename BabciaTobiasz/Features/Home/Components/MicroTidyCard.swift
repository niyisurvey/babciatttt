//
//  MicroTidyCard.swift
//  BabciaTobiasz
//

import SwiftUI

struct MicroTidyCard: View {
    let onTap: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            onTap()
        }) {
            GlassCardView {
                HStack(spacing: 16) {
                    Image(systemName: "wand.and.stars")
                        .foregroundStyle(theme.palette.warmAccent)
                        .font(.system(size: theme.grid.iconLarge))
                        .symbolEffect(.pulse, options: .repeating)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "home.microTidy.title"))
                            .dsFont(.headline)
                        Text(String(localized: "home.microTidy.subtitle"))
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
        MicroTidyCard(onTap: {})
            .padding()
    }
    .dsTheme(.default)
}
