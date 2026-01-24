//
//  LatestDreamCard.swift
//  BabciaTobiasz
//
//  Created 2026-01-15 (Claude Code - Phase 1.1)
//  Displays latest Dream image preview
//

import SwiftUI

struct LatestDreamCard: View {
    let dreamImageData: Data?
    let onTap: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            onTap()
        }) {
            GlassCardView {
                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                    HStack {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(theme.palette.primary)
                            .font(.system(size: theme.grid.iconTitle3))
                            .symbolEffect(.pulse, options: .repeating)

                        Text(String(localized: "home.latestDream.title"))
                            .dsFont(.headline)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .font(.system(size: theme.grid.iconSmall))
                    }

                    if let data = dreamImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                    } else {
                        emptyDreamPlaceholder
                    }
                }
                .padding(theme.grid.cardPadding)
            }
        }
        .buttonStyle(.plain)
        .scrollTransition { content, phase in
            content
                .opacity(phase.isIdentity ? 1 : 0.8)
                .scaleEffect(phase.isIdentity ? 1 : 0.98)
                .blur(radius: phase.isIdentity ? 0 : 2)
        }
    }

    private var emptyDreamPlaceholder: some View {
        ZStack {
            theme.palette.neutral.opacity(0.08)
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.system(size: theme.grid.iconLarge))
                    .foregroundStyle(theme.palette.textSecondary)

                Text(String(localized: "home.latestDream.empty"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 180)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            LatestDreamCard(dreamImageData: nil, onTap: {})
            LatestDreamCard(dreamImageData: Data(), onTap: {})
        }
        .padding()
    }
    .dsTheme(.default)
}
