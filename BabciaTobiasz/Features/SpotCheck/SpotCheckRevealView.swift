//
//  SpotCheckRevealView.swift
//  BabciaTobiasz
//

import SwiftUI

struct SpotCheckRevealView: View {
    let message: String

    var body: some View {
        GlassCardView {
            LoadingIndicatorView(message: message, size: .medium, showBackground: false)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
    }
}

#Preview {
    SpotCheckRevealView(message: String(localized: "spotCheck.reveal.message"))
        .environment(AppDependencies())
}
