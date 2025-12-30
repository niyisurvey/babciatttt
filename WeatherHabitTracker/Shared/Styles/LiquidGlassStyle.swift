// LiquidGlassStyle.swift
// WeatherHabitTracker

import SwiftUI

// MARK: - Liquid Glass Modifier

/// Applies native iOS 26 Liquid Glass effects with fallback
struct NativeLiquidGlass: ViewModifier {
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(true), in: .rect(cornerRadius: cornerRadius))
        } else {
            fallbackContent(content)
        }
        #else
        fallbackContent(content)
        #endif
    }
    
    @ViewBuilder
    private func fallbackContent(_ content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    /// Applies Liquid Glass effect
    func liquidGlass(cornerRadius: CGFloat = 24) -> some View {
        modifier(NativeLiquidGlass(cornerRadius: cornerRadius))
    }
    
    /// Prominent glass effect for buttons
    @ViewBuilder
    func liquidGlassProminent(cornerRadius: CGFloat = 24) -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(.regular.tint(.accentColor), in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        #else
        self.background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        #endif
    }
    
    /// Subtle glass effect
    @ViewBuilder
    func subtleGlass() -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(.regular, in: .rect(cornerRadius: 12))
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        #else
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        #endif
    }
    
    /// Concentric clip shape for nested elements
    @ViewBuilder
    func concentricClipShape(cornerRadius: CGFloat = 20) -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            self.clipShape(ConcentricRectangle())
        } else {
            self.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        #else
        self.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        #endif
    }
}

// MARK: - Glass Background

struct LiquidGlassBackground: View {
    var style: BackgroundStyle = .default
    
    enum BackgroundStyle { case `default`, weather, habits }
    
    var body: some View {
        switch style {
        case .default: defaultBackground
        case .weather: weatherBackground
        case .habits: habitsBackground
        }
    }
    
    private var defaultBackground: some View {
        #if os(iOS)
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .blue.opacity(0.2), .cyan.opacity(0.15), .teal.opacity(0.2),
                .purple.opacity(0.1), .blue.opacity(0.1), .cyan.opacity(0.15),
                .indigo.opacity(0.15), .purple.opacity(0.1), .blue.opacity(0.2)
            ]
        )
        .ignoresSafeArea()
        #else
        LinearGradient(
            colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .controlBackgroundColor)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
        #endif
    }
    
    private var weatherBackground: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.6, 0.4], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                Color(red: 0.4, green: 0.7, blue: 0.9), Color(red: 0.5, green: 0.8, blue: 0.95), Color(red: 0.6, green: 0.85, blue: 1.0),
                Color(red: 0.5, green: 0.75, blue: 0.9), Color(red: 0.55, green: 0.8, blue: 0.92), Color(red: 0.6, green: 0.82, blue: 0.95),
                Color(red: 0.5, green: 0.7, blue: 0.85), Color(red: 0.55, green: 0.75, blue: 0.88), Color(red: 0.6, green: 0.78, blue: 0.9)
            ]
        )
        .ignoresSafeArea()
    }
    
    private var habitsBackground: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                .green.opacity(0.25), .teal.opacity(0.2), .cyan.opacity(0.25),
                .mint.opacity(0.15), .green.opacity(0.2), .teal.opacity(0.2),
                .teal.opacity(0.2), .mint.opacity(0.15), .green.opacity(0.25)
            ]
        )
        .ignoresSafeArea()
    }
}
