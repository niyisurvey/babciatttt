//
//  BabciaPersonaSelectionView.swift
//  BabciaTobiasz
//

import SwiftUI

struct BabciaPersonaSelectionView: View {
    @Binding var selectedPersona: BabciaPersona
    @Environment(\.dsTheme) private var theme
    @State private var detailPersona: BabciaPersona = .classic
    @State private var showPersonaDetail = false

    var body: some View {
        VStack(spacing: theme.grid.sectionSpacing) {
            header

            ZStack {
                inviteAura
                personaCarousel
            }
            .frame(height: theme.grid.heroCardHeight + theme.grid.iconLarge)

            Text(String(localized: "onboarding.persona.helper"))
                .dsFont(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.grid.cardPadding)
        }
        .padding(.horizontal, theme.grid.cardPadding)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(String(localized: "onboarding.persona.title"))
                .dsFont(.title, weight: .bold)
                .multilineTextAlignment(.center)

            Text(String(localized: "onboarding.persona.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.grid.cardPadding)
        }
    }

    private var personaCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: theme.grid.listSpacing) {
                ForEach(BabciaPersona.allCases) { persona in
                    Button {
                        let wasSelected = selectedPersona == persona
                        withAnimation(theme.motion.listSpring) {
                            selectedPersona = persona
                        }
                        if wasSelected {
                            detailPersona = persona
                            showPersonaDetail = true
                        }
                        hapticFeedback(.selection)
                    } label: {
                        BabciaPersonaCard(
                            persona: persona,
                            isSelected: persona == selectedPersona,
                            accentColor: accentColor(for: persona)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.grid.cardPadding)
        }
        .sheet(isPresented: $showPersonaDetail) {
            BabciaPersonaDetailSheet(persona: detailPersona)
        }
    }

    private var inviteAura: some View {
        BabciaInviteAuraView(accentColor: accentColor(for: selectedPersona))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func accentColor(for persona: BabciaPersona) -> Color {
        switch persona {
        case .classic: return theme.palette.warmAccent
        case .baroness: return theme.palette.coolAccent
        case .warrior: return theme.palette.error
        case .wellness: return theme.palette.tertiary
        case .coach: return theme.palette.primary
        }
    }
}

private struct BabciaPersonaCard: View {
    let persona: BabciaPersona
    let isSelected: Bool
    let accentColor: Color
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(spacing: 12) {
                personaHeadshot
                VStack(spacing: 4) {
                    Text(persona.localizedDisplayName)
                        .dsFont(.headline, weight: .bold)
                    Text(persona.localizedArchetype)
                        .dsFont(.caption, weight: .bold)
                        .foregroundStyle(accentColor)
                    Text(persona.localizedTagline)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    Text("“\(persona.localizedQuote)”")
                        .dsFont(.caption2, weight: .bold)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(theme.grid.cardPadding)
        }
        .overlay(selectionRing)
        .overlay(alignment: .topTrailing) {
            Image(systemName: "info.circle")
                .font(.system(size: theme.grid.iconTiny))
                .foregroundStyle(accentColor)
                .padding(.top, 8)
                .padding(.trailing, 8)
        }
        .scaleEffect(isSelected ? 1.02 : 0.98)
        .animation(theme.motion.listSpring, value: isSelected)
    }

    @ViewBuilder
    private var personaHeadshot: some View {
        if let uiImage = UIImage(named: persona.headshotImageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: theme.grid.iconXXL, height: theme.grid.iconXXL)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(theme.glass.strength.fallbackMaterial)
                .frame(width: theme.grid.iconXXL, height: theme.grid.iconXXL)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: theme.grid.iconMedium))
                        .foregroundStyle(accentColor)
                )
        }
    }

    private var selectionRing: some View {
        Circle()
            .strokeBorder(accentColor, lineWidth: isSelected ? 3 : 1)
            .frame(width: theme.grid.iconXXL + 16, height: theme.grid.iconXXL + 16)
            .shadow(color: accentColor.opacity(isSelected ? 0.35 : 0), radius: 12)
            .opacity(isSelected ? 1 : 0.3)
            .offset(y: -theme.grid.cardPadding)
    }
}

private struct BabciaPersonaDetailSheet: View {
    let persona: BabciaPersona
    @Environment(\.dsTheme) private var theme

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground(style: .default)
                ScrollView {
                    VStack(spacing: theme.grid.sectionSpacing) {
                        header
                        detailCard
                        quoteCard
                    }
                    .padding(theme.grid.cardPadding)
                }
            }
            .navigationTitle("")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(persona.localizedDisplayName)
                        .dsFont(.headline, weight: .bold)
                }
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            if let uiImage = UIImage(named: persona.headshotImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: theme.grid.iconXXL, height: theme.grid.iconXXL)
                    .clipShape(Circle())
            }
            Text(persona.localizedArchetype)
                .dsFont(.headline, weight: .bold)
                .foregroundStyle(theme.palette.primary)
            Text(persona.localizedTagline)
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var detailCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "persona.detail.title"))
                    .dsFont(.headline, weight: .bold)
                Text(persona.localizedDescription)
                    .dsFont(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(theme.grid.cardPadding)
        }
    }

    private var quoteCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "persona.detail.quoteTitle"))
                    .dsFont(.headline, weight: .bold)
                Text("“\(persona.localizedQuote)”")
                    .dsFont(.subheadline, weight: .bold)
                    .foregroundStyle(theme.palette.secondary)
            }
            .padding(theme.grid.cardPadding)
        }
    }
}

private struct BabciaInviteAuraView: View {
    let accentColor: Color
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.shape.heroCornerRadius)
                .fill(
                    LinearGradient(
                        colors: [
                            accentColor.opacity(0.35),
                            theme.palette.primary.opacity(0.2),
                            theme.palette.secondary.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blur(radius: 26)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            accentColor.opacity(0.6),
                            theme.palette.coolAccent.opacity(0.2),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 220
                    )
                )
                .blendMode(.screen)
                .blur(radius: 30)
        }
        .phaseAnimator([false, true]) { content, shift in
            content
                .hueRotation(.degrees(shift ? 320 : 0))
                .scaleEffect(shift ? 1.05 : 0.95)
                .opacity(shift ? 0.9 : 0.7)
        } animation: { _ in
            .easeInOut(duration: 2.4)
        }
    }
}

#Preview {
    BabciaPersonaSelectionView(selectedPersona: .constant(.classic))
        .dsTheme(.default)
}
