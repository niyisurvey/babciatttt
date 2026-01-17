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
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundStyle(.yellow)
                            .font(.system(size: theme.grid.iconTitle3))
                            .symbolEffect(.pulse, options: .repeating)

                        Text("Latest Dream")
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
                            .clipShape(RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius))
                    } else {
                        emptyDreamPlaceholder
                    }
                }
                .padding()
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
        RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius)
            .fill(theme.palette.glassTint.opacity(0.05))
            .frame(height: 180)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: theme.grid.iconLarge))
                        .foregroundStyle(.secondary)

                    Text("No Dreams yet")
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }
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
