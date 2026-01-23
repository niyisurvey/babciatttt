//
//  AppHost.swift
//  BabciaTobiasz
//
//  iOS app entry point for the Xcode app target.
//

import SwiftUI

@main
struct BabciaTobiaszApp: App {
    private let theme = DesignSystemTheme.default

    var body: some Scene {
        WindowGroup {
            BabciaTobiaszAppView()
                .dsTheme(theme)
                .environment(\.font, theme.typography.font(.body))
        }
    }
}
