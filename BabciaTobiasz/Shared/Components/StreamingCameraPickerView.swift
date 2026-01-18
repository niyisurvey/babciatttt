//
//  StreamingCameraPickerView.swift
//  BabciaTobiasz
//

import SwiftUI

struct StreamingCameraPickerView: View {
    let cameras: [StreamingCameraConfig]
    let onSelect: (StreamingCameraConfig) -> Void
    let onCancel: () -> Void

    @Environment(\.dsTheme) private var theme

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground(style: .default)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: theme.grid.sectionSpacing) {
                        if cameras.isEmpty {
                            emptyStateCard
                        } else {
                            cameraList
                        }
                    }
                    .padding(theme.grid.cardPadding)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "cameraSource.pick.title"))
                        .dsFont(.title2, weight: .bold)
                        .lineLimit(1)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        onCancel()
                    }
                }
            }
        }
    }

    private var emptyStateCard: some View {
        GlassCardView {
            Text(String(localized: "cameraSource.empty"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var cameraList: some View {
        VStack(spacing: theme.grid.listSpacing) {
            ForEach(cameras) { camera in
                Button {
                    onSelect(camera)
                } label: {
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(camera.name)
                                .dsFont(.headline, weight: .bold)
                            Text(camera.providerType.localizedName)
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    StreamingCameraPickerView(cameras: [], onSelect: { _ in }, onCancel: {})
        .environment(AppDependencies())
        .modelContainer(for: [StreamingCameraConfig.self], inMemory: true)
}
