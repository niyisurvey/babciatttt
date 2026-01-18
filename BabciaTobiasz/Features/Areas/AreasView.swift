// AreasView.swift
// BabciaTobiasz

import SwiftUI

/// Areas screen highlights a hero image card.
struct AreasView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground(style: .areas)
                ScrollView {
                    AreasHeroCard()
                        .padding()
                }
            }
            .navigationTitle(String(localized: "areas.toolbar.title"))
        }
    }
}

private struct AreasHeroCard: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView(padding: 0) {
            Image("DreamRoom_Test_1200x1600")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: theme.grid.heroCardHeight)
                .clipped()
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
    AreasView()
        .environment(AppDependencies())
}
