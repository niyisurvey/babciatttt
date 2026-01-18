//
//  DreamHeaderPlaceholderView.swift
//  BabciaTobiasz
//

import SwiftUI

struct DreamHeaderPlaceholderView: View {
    let title: String
    let message: String
    let icon: String

    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    theme.palette.primary.opacity(0.25),
                    theme.palette.secondary.opacity(0.2),
                    theme.palette.tertiary.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: theme.grid.iconXL))
                    .foregroundStyle(theme.palette.primary)
                Text(title)
                    .dsFont(.title3, weight: .bold)
                    .multilineTextAlignment(.center)
                Text(message)
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(theme.grid.cardPadding)
        }
    }
}

#Preview {
    DreamHeaderPlaceholderView(
        title: "Start your first check-in",
        message: "Snap a photo to generate tasks and dream visions.",
        icon: "sparkles"
    )
    .frame(height: 260)
    .dsTheme(.default)
}
