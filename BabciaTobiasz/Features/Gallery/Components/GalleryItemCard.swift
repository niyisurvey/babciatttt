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
        bowl.area?.name ?? String(localized: "gallery.detail.area.fallback")
    }

    private var subtitle: String {
        bowl.createdAt.formatted(date: .abbreviated, time: .omitted)
    }

    private var personaName: String {
        let raw = bowl.area?.personaRaw ?? BabciaPersona.classic.rawValue
        return BabciaPersona(rawValue: raw)?.localizedDisplayName ?? raw.capitalized
    }

    private var personaLabel: String {
        String(format: String(localized: "gallery.card.persona"), personaName)
    }

    private var persona: BabciaPersona {
        let raw = bowl.area?.personaRaw ?? BabciaPersona.classic.rawValue
        return BabciaPersona(rawValue: raw) ?? .classic
    }

    var body: some View {
        Button(action: {
            hapticFeedback(.light)
            onTap()
        }) {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                GalleryImageView(imageData: bowl.galleryImageData)
                    .frame(height: theme.grid.detailCardHeightLarge)
                    .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .dsFont(.caption, weight: .bold)
                        .lineLimit(1)
                    Text(subtitle)
                        .dsFont(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(theme.grid.cardPaddingTight)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius))
        }
        .buttonStyle(.plain)
    }

    private var personaBadge: some View {
        HStack(spacing: 6) {
            personaHeadshot
            Text(persona.localizedDisplayName)
                .dsFont(.caption2, weight: .bold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(theme.palette.glassTint.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var personaHeadshot: some View {
        if let uiImage = UIImage(named: persona.headshotImageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: theme.grid.iconTiny + 8, height: theme.grid.iconTiny + 8)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(theme.glass.strength.fallbackMaterial)
                .frame(width: theme.grid.iconTiny + 8, height: theme.grid.iconTiny + 8)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: theme.grid.iconTiny))
                        .foregroundStyle(theme.palette.secondary)
                )
        }
    }
}

#Preview {
    GalleryItemCard(bowl: AreaBowl(), onTap: {})
        .padding()
        .dsTheme(.default)
}
