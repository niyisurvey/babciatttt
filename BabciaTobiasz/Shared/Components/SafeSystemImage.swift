// SafeSystemImage.swift
// BabciaTobiasz

import SwiftUI
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

struct SafeSystemImage: View {
    let name: String
    let fallback: String

    init(_ name: String, fallback: String) {
        self.name = name
        self.fallback = fallback
    }

    @ViewBuilder
    var body: some View {
        if symbolExists(name) {
            Image(systemName: name)
        } else {
            Image(systemName: fallback)
        }
    }

    private func symbolExists(_ name: String) -> Bool {
        #if os(iOS)
        return UIImage(systemName: name) != nil
        #elseif os(macOS)
        return NSImage(systemSymbolName: name, accessibilityDescription: nil) != nil
        #else
        return true
        #endif
    }
}
