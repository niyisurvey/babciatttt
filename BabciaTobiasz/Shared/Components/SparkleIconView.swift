//
//  SparkleIconView.swift
//  BabciaTobiasz
//

import SwiftUI

struct SparkleIconView: View {
    let systemName: String
    let size: CGFloat
    let color: Color
    var sparkleColor: Color? = nil
    var sparkleScale: CGFloat = 0.32

    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: systemName)
                .font(theme.typography.custom(size: size, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(color)

            Image(systemName: "sparkles")
                .font(.system(size: max(10, size * sparkleScale)))
                .foregroundStyle(sparkleColor ?? theme.palette.warmAccent)
                .offset(x: size * 0.22, y: -size * 0.22)
                .applySparklePulse()
        }
        .frame(width: size, height: size)
    }
}

private extension View {
    @ViewBuilder
    func applySparklePulse() -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 17.0, macOS 14.0, *) {
            self.symbolEffect(.pulse, options: .repeating)
        } else {
            self
        }
        #else
        self
        #endif
    }
}

#Preview {
    let theme = DesignSystemTheme.default
    SparkleIconView(systemName: "checkmark.seal.fill", size: theme.grid.iconXL, color: theme.palette.warning)
        .padding()
        .dsTheme(.default)
}
