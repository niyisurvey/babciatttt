//
//  CompletionSummaryView.swift
//  BabciaTobiasz
//

import SwiftUI

struct CompletionSummaryView: View {
    let persona: BabciaPersona
    let tier: BowlVerificationTier
    let bluePoints: Int
    let goldenPoints: Int
    let onVerify: () -> Void
    let onDone: () -> Void

    @Environment(\.dsTheme) private var theme

    private var bowlAssetName: String {
        tier == .blue ? "Bowl_Clay_Blue" : "Bowl_Clay_Natural"
    }

    private var pierogiAssetName: String {
        tier == .golden ? "Pierogi_Clay_Golden" : "Pierogi_Clay_Normal"
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            VStack(spacing: theme.grid.sectionSpacing) {
                header

                personaHero

                bowlReward

                VStack(spacing: theme.grid.cardPaddingTight) {
                    Text(String(localized: "areaDetail.completion.message"))
                        .dsFont(.subheadline)
                        .foregroundStyle(theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                    Text(String(format: String(localized: "areaDetail.completion.points"), pointsReward))
                        .dsFont(.caption)
                        .foregroundStyle(theme.palette.textSecondary)
                }
                .padding(.horizontal, theme.grid.cardPadding)

                VStack(spacing: theme.grid.listSpacing) {
                    Button {
                        onVerify()
                        hapticFeedback(.medium)
                    } label: {
                        Label(String(localized: "areaDetail.completion.primary"), systemImage: "checkmark.seal.fill")
                            .dsFont(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.nativeGlassProminent)

                    Button {
                        onDone()
                        hapticFeedback(.light)
                    } label: {
                        Text(String(localized: "areaDetail.completion.secondary"))
                            .dsFont(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.nativeGlass)
                }
                .padding(.horizontal, theme.grid.cardPadding)
            }
            .padding(.vertical, theme.grid.sectionSpacing)
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(String(localized: "areaDetail.completion.title"))
                .dsFont(.title2, weight: .bold)
            Text(String(localized: "areaDetail.completion.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    private var personaHero: some View {
        Image(persona.fullBodyImageName(for: .victory))
            .resizable()
            .scaledToFit()
            .frame(maxHeight: theme.grid.heroCardHeight)
    }

    private var bowlReward: some View {
        ZStack {
            Image(bowlAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: theme.grid.pierogiPotSize, height: theme.grid.pierogiPotSize)
            Image(pierogiAssetName)
                .resizable()
                .scaledToFit()
                .frame(width: theme.grid.pierogiSize, height: theme.grid.pierogiSize)
                .offset(y: -theme.grid.iconSmall)
        }
    }

    private var pointsReward: Int {
        tier == .golden ? goldenPoints : bluePoints
    }
}

#Preview {
    CompletionSummaryView(
        persona: .classic,
        tier: .golden,
        bluePoints: 25,
        goldenPoints: 50,
        onVerify: {},
        onDone: {}
    )
    .dsTheme(.default)
}
