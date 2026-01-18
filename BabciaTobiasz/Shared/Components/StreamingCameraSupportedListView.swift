//
//  StreamingCameraSupportedListView.swift
//  BabciaTobiasz
//

import SwiftUI

struct StreamingCameraSupportedListView: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            supportedRow(icon: "dot.radiowaves.left.and.right", title: "camera.supported.rtsp.title", detail: "camera.supported.rtsp.detail")
            supportedRow(icon: "video.fill", title: "camera.supported.tapo.title", detail: "camera.supported.tapo.detail")
            supportedRow(icon: "house.fill", title: "camera.supported.ha.title", detail: "camera.supported.ha.detail")
        }
    }

    private func supportedRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: theme.grid.iconSmall))
                .foregroundStyle(theme.palette.primary)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: title))
                    .dsFont(.subheadline, weight: .bold)
                Text(String(localized: detail))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    StreamingCameraSupportedListView()
        .dsTheme(.default)
}
