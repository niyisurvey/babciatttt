//
//  GalleryImageView.swift
//  BabciaTobiasz
//
//  Created 2026-01-15
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct GalleryImageView: View {
    let imageData: Data?
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius)
                .fill(.ultraThinMaterial)

            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .clipShape(
                        RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius)
                    )
            } else {
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
                    .font(.system(size: theme.grid.iconLarge))
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius)
                .strokeBorder(.white.opacity(0.08))
        )
        .clipped()
    }
}

extension AreaBowl {
    var galleryImageData: Data? {
        dreamHeroImageData ?? dreamRawImageData ?? afterPhotoData ?? beforePhotoData
    }
}
