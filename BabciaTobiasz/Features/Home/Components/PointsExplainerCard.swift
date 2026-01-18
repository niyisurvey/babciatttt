//
//  PointsExplainerCard.swift
//  BabciaTobiasz
//

import SwiftUI

struct PointsExplainerCard: View {
    @AppStorage("home.pointsExplainerShown") private var pointsExplainerShown = false
    @Environment(\.dsTheme) private var theme

    var body: some View {
        if pointsExplainerShown == false {
            GlassCardView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .foregroundStyle(theme.palette.warmAccent)
                        Text(String(localized: "home.pointsExplainer.title"))
                            .dsFont(.headline, weight: .bold)
                    }

                    Text(String(localized: "home.pointsExplainer.message"))
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)

                    Button(String(localized: "home.pointsExplainer.action")) {
                        pointsExplainerShown = true
                        hapticFeedback(.light)
                    }
                    .buttonStyle(.nativeGlass)
                }
                .padding(theme.grid.cardPadding)
            }
            .scrollTransition { content, phase in
                content
                    .opacity(phase.isIdentity ? 1 : 0.8)
                    .scaleEffect(phase.isIdentity ? 1 : 0.98)
                    .blur(radius: phase.isIdentity ? 0 : 2)
            }
        }
    }
}

#Preview {
    ScrollView {
        PointsExplainerCard()
            .padding()
    }
    .dsTheme(.default)
}
