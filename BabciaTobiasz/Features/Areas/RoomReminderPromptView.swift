//
//  RoomReminderPromptView.swift
//  BabciaTobiasz
//

import SwiftUI

struct RoomReminderPromptView: View {
    let area: Area
    let onStart: () -> Void
    let onDismiss: () -> Void

    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .areas)

            VStack(spacing: theme.grid.sectionSpacing) {
                GlassCardView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "reminderPrompt.title"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)

                        Text(area.name)
                            .dsFont(.title2, weight: .bold)

                        Text(String(localized: "reminderPrompt.message"))
                            .dsFont(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: theme.grid.listSpacing) {
                    Button(String(localized: "common.notNow")) {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)

                    Button(String(localized: "reminderPrompt.start")) {
                        onStart()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}
