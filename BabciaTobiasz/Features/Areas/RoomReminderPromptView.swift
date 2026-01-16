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
                        Text("Room reminder")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)

                        Text(area.name)
                            .dsFont(.title2, weight: .bold)

                        Text("Ready to start a quick scan and refresh your tasks?")
                            .dsFont(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: theme.grid.listSpacing) {
                    Button("Not now") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)

                    Button("Start scan") {
                        onStart()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
}
