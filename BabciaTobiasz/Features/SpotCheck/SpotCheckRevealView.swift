//
//  SpotCheckRevealView.swift
//  BabciaTobiasz
//

import SwiftUI

struct SpotCheckRevealView: View {
    let message: String

    var body: some View {
        GlassCardView {
            VStack(spacing: 8) {
                LoadingIndicatorView(message: message, size: .medium, showBackground: false)
                Text(String(localized: "spotCheck.reveal.spinning"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    SpotCheckRevealView(message: String(localized: "spotCheck.reveal.message"))
        .environment(AppDependencies())
}
