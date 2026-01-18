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
            GlassCardView {
                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                    ZStack(alignment: .bottomTrailing) {
                        GalleryImageView(imageData: bowl.galleryImageData)
                            .frame(height: theme.grid.detailCardHeightLarge)
                        personaBadge
                            .padding(theme.grid.cardPaddingTight)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .dsFont(.headline, weight: .bold)
                            .lineLimit(1)

                        Text(personaLabel)
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
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
