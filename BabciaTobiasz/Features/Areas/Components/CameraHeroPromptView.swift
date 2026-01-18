//
//  CameraHeroPromptView.swift
//  BabciaTobiasz
//
//  Hero prompt shown before opening the camera.
//

import SwiftUI

struct CameraHeroPromptView: View {
    let area: Area
    let onStart: () -> Void
    let onDismiss: () -> Void

    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .areas)

            VStack(spacing: theme.grid.sectionSpacing) {
                VStack(spacing: theme.grid.cardPaddingTight) {
                    Text(String(localized: "cameraHero.title"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)

                    Text(area.name)
                        .dsFont(.title2, weight: .bold)

                    Text(area.persona.localizedTagline)
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, theme.grid.cardPadding)

                heroImage
                    .frame(maxWidth: .infinity)
                    .frame(height: theme.grid.heroCardHeight + theme.grid.iconXL)

                HStack(spacing: theme.grid.listSpacing) {
                    Button(String(localized: "common.notNow")) {
                        onDismiss()
                    }
                    .buttonStyle(.nativeGlass)

                    Button(String(localized: "cameraHero.primary")) {
                        onStart()
                    }
                    .buttonStyle(.nativeGlassProminent)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private var heroImage: some View {
        if let uiImage = UIImage(named: area.persona.fullBodyHeroImageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .shadow(color: theme.palette.glassTint.opacity(0.2), radius: theme.grid.iconLarge, x: 0, y: theme.grid.iconSmall)
        } else {
            personaFallback
        }
    }

    private var personaFallback: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius, style: .continuous)
                .fill(theme.glass.strength.fallbackMaterial)

            Image(systemName: "person.fill")
                .font(.system(size: theme.grid.iconXL))
                .foregroundStyle(theme.palette.secondary)
        }
    }
}

#Preview {
    CameraHeroPromptView(area: Area.sampleAreas[0], onStart: {}, onDismiss: {})
        .dsTheme(.default)
}
