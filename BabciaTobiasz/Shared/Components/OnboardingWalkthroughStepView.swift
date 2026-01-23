//
//  OnboardingWalkthroughStepView.swift
//  BabciaTobiasz
//

import SwiftUI

struct OnboardingWalkthroughStepView: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(spacing: theme.grid.sectionSpacing) {
            header

            GlassCardView {
                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                    walkthroughRow(icon: "camera.fill", title: "onboarding.tutorial.step.scan.title", detail: "onboarding.tutorial.step.scan.detail")
                    walkthroughRow(icon: "checklist", title: "onboarding.tutorial.step.tasks.title", detail: "onboarding.tutorial.step.tasks.detail")
                    walkthroughRow(icon: "checkmark.circle.fill", title: "onboarding.tutorial.step.complete.title", detail: "onboarding.tutorial.step.complete.detail")
                    walkthroughRow(icon: "checkmark.seal.fill", title: "onboarding.tutorial.step.verify.title", detail: "onboarding.tutorial.step.verify.detail")
                }
                .padding(theme.grid.cardPadding)
            }

        }
        .padding(.horizontal, theme.grid.cardPadding)
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(String(localized: "onboarding.tutorial.title"))
                .dsFont(.title, weight: .bold)
                .multilineTextAlignment(.center)

            Text(String(localized: "onboarding.tutorial.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private func walkthroughRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            SparkleIconView(systemName: icon, size: theme.grid.iconSmall, color: theme.palette.warmAccent)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(title))
                    .dsFont(.subheadline, weight: .bold)
                Text(LocalizedStringKey(detail))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingWalkthroughStepView()
        .dsTheme(.default)
}
