//
//  ScanProcessingOverlayView.swift
//  BabciaTobiasz
//

import SwiftUI

struct ScanProcessingOverlayView: View {
    let persona: BabciaPersona
    @Environment(\.dsTheme) private var theme

    private let progressSteps = [
        String(localized: "areas.scan.progress.analyzing"),
        String(localized: "areas.scan.progress.tasks"),
        String(localized: "areas.scan.progress.dream")
    ]

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            GlassCardView {
                VStack(spacing: theme.grid.sectionSpacing) {
                    portraitView

                    Text(String(localized: "areas.scan.progress.title"))
                        .dsFont(.headline, weight: .bold)

                    TimelineView(.animation(minimumInterval: 1.8)) { timeline in
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(progressSteps.indices, id: \.self) { index in
                                let isActive = index <= messageIndex(for: timeline.date)
                                HStack(spacing: 8) {
                                    Image(systemName: isActive ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(isActive ? theme.palette.primary : .secondary)
                                    Text(progressSteps[index])
                                        .dsFont(.subheadline, weight: isActive ? .bold : .regular)
                                        .foregroundStyle(isActive ? .primary : .secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
        guard progressSteps.isEmpty == false else { return 0 }
        let interval = Int(date.timeIntervalSince1970 / 2)
        return abs(interval) % progressSteps.count
    }
}

#Preview {
    ScanProcessingOverlayView(persona: .classic)
        .dsTheme(.default)
}
