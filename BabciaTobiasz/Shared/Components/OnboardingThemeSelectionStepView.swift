//
//  OnboardingThemeSelectionStepView.swift
//  BabciaTobiasz
//

import SwiftUI

struct OnboardingThemeSelectionStepView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(spacing: theme.grid.sectionSpacing) {
            header

            GlassCardView {
                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                    Text(String(localized: "onboarding.theme.helper"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)

                    Picker(String(localized: "onboarding.theme.title"), selection: $appTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.localizedName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(theme.grid.cardPadding)
            }
        }
        .padding(.horizontal, theme.grid.cardPadding)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(String(localized: "onboarding.theme.title"))
                .dsFont(.title, weight: .bold)
                .multilineTextAlignment(.center)

            Text(String(localized: "onboarding.theme.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnboardingThemeSelectionStepView()
        .dsTheme(.default)
}
