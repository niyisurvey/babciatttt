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
    @AppStorage("primaryPersonaRaw") private var primaryPersonaRaw: String = BabciaPersona.classic.rawValue

    private var persona: BabciaPersona {
        BabciaPersona(rawValue: primaryPersonaRaw) ?? .classic
    }

    var body: some View {
        GlassCardView(padding: 0) {
            if let uiImage = UIImage(named: persona.fullBodyImageName(for: .happy)) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: theme.grid.heroCardHeight)
                    .clipped()
            } else {
                DreamHeaderPlaceholderView(
                    title: String(localized: "areas.hero.placeholder.title"),
                    message: String(localized: "areas.hero.placeholder.message"),
                    icon: "sparkles"
                )
                .frame(height: theme.grid.heroCardHeight)
            }
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
