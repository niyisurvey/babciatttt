//
//  ChangelogView.swift
//  BabciaTobiasz
//

import SwiftUI

struct ChangelogView: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView {
                VStack(spacing: theme.grid.sectionSpacing) {
                    header
                    changelogCard
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
                Text(String(localized: "changelog.title"))
                    .dsFont(.headline, weight: .bold)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(String(localized: "changelog.title"))
                .dsFont(.title2, weight: .bold)
            Text(String(localized: "changelog.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var changelogCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "changelog.section.latest"))
                    .dsFont(.headline, weight: .bold)

                ChangelogRow(text: String(localized: "changelog.item.1"))
                ChangelogRow(text: String(localized: "changelog.item.2"))
                ChangelogRow(text: String(localized: "changelog.item.3"))
            }
            .padding(theme.grid.cardPadding)
        }
    }
}

private struct ChangelogRow: View {
    let text: String
    @Environment(\.dsTheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: theme.grid.iconTiny))
                .foregroundStyle(theme.palette.warmAccent)
                .padding(.top, 2)
            Text(text)
                .dsFont(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        ChangelogView()
    }
    .dsTheme(.default)
}
