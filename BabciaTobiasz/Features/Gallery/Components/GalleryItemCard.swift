//
//  GalleryItemCard.swift
//  BabciaTobiasz
//
//  Created 2026-01-15
//

import SwiftUI

struct GalleryItemCard: View {
    let bowl: AreaBowl
    let onTap: () -> Void
    @Environment(\.dsTheme) private var theme

    private var title: String {
        bowl.area?.name ?? "Area"
    }

    private var subtitle: String {
        bowl.createdAt.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            onTap()
        }) {
            GlassCardView {
                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                    GalleryImageView(imageData: bowl.galleryImageData)
                        .frame(height: theme.grid.detailCardHeightLarge)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .dsFont(.headline, weight: .bold)
                            .lineLimit(1)

                        Text(subtitle)
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
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
}

#Preview {
    GalleryItemCard(bowl: AreaBowl(), onTap: {})
        .padding()
        .dsTheme(.default)
}
