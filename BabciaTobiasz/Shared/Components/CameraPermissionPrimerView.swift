//
//  CameraPermissionPrimerView.swift
//  BabciaTobiasz
//
//  Primer shown before iOS camera permission prompts.
//

import SwiftUI

struct CameraPermissionPrimerView: View {
    let title: String
    let message: String
    let bullets: [String]
    let primaryActionTitle: String
    let secondaryActionTitle: String
    let onContinue: () -> Void
    let onNotNow: () -> Void

    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            VStack(spacing: theme.grid.sectionSpacing) {
                Spacer()

                GlassCardView {
                    VStack(alignment: .leading, spacing: theme.grid.sectionSpacing) {
                        HStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: theme.grid.iconLarge))
                                .foregroundStyle(theme.palette.primary)
                                .symbolEffect(.pulse, options: .repeating)
                            Text(title)
                                .dsFont(.title2, weight: .bold)
                        }

                        Text(message)
                            .dsFont(.body)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(bullets, id: \.self) { bullet in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: theme.grid.iconTiny))
                                        .foregroundStyle(theme.palette.warmAccent)
                                        .padding(.top, 3)
                                    Text(bullet)
                                        .dsFont(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        HStack(spacing: theme.grid.listSpacing) {
                            Button(secondaryActionTitle) {
                                onNotNow()
                            }
                            .buttonStyle(.nativeGlass)

                            Button(primaryActionTitle) {
                                onContinue()
                            }
                            .buttonStyle(.nativeGlassProminent)
                        }
                    }
                    .padding(theme.grid.cardPadding)
                }
                .padding(.horizontal, theme.grid.cardPadding)

                Spacer()
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    CameraPermissionPrimerView(
        title: "Camera access",
        message: "Babcia uses your camera to see your rooms and create cleaning tasks.",
        bullets: [
            "We only capture when you tap the camera button.",
            "Photos stay on your device unless you request verification."
        ],
        primaryActionTitle: "Continue",
        secondaryActionTitle: "Not now",
        onContinue: {},
        onNotNow: {}
    )
    .dsTheme(.default)
}
