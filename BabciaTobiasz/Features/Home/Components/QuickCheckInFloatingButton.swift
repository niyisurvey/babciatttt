//
//  QuickCheckInFloatingButton.swift
//  BabciaTobiasz
//

import SwiftUI

struct QuickCheckInFloatingButton: View {
    let action: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        Button {
            hapticFeedback(.medium)
            action()
        } label: {
            Label(String(localized: "home.quickCheckIn"), systemImage: "camera.fill")
                .dsFont(.headline, weight: .bold)
        }
        .buttonStyle(.nativeGlassProminent)
        .accessibilityLabel(String(localized: "home.quickCheckIn"))
    }
}

#Preview {
    QuickCheckInFloatingButton(action: {})
        .padding()
        .dsTheme(.default)
        .background(Color.gray.opacity(0.1))
}
