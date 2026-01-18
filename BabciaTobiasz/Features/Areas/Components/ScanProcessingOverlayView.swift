//
//  ScanProcessingOverlayView.swift
//  BabciaTobiasz
//

import SwiftUI

struct ScanProcessingOverlayView: View {
    let persona: BabciaPersona
    @Environment(\.dsTheme) private var theme

    private let statusMessages = [
        String(localized: "areas.scan.status.thinking1"),
        String(localized: "areas.scan.status.thinking2"),
        String(localized: "areas.scan.status.thinking3")
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            GlassCardView {
                VStack(spacing: theme.grid.sectionSpacing) {
                    portraitView

                    TimelineView(.animation(minimumInterval: 1.8)) { timeline in
                        Text(statusMessages[messageIndex(for: timeline.date)])
                            .dsFont(.headline, weight: .bold)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(theme.grid.cardPadding)
                .frame(maxWidth: 320)
            }
        }
        .transition(.opacity)
    }

    @ViewBuilder
    private var portraitView: some View {
        Image(persona.portraitThinkingImageName)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: theme.grid.heroCardHeight * 0.7)
    }

    private func messageIndex(for date: Date) -> Int {
        guard statusMessages.isEmpty == false else { return 0 }
        let interval = Int(date.timeIntervalSince1970 / 2)
        return abs(interval) % statusMessages.count
    }
}

#Preview {
    ScanProcessingOverlayView(persona: .classic)
        .dsTheme(.default)
}
