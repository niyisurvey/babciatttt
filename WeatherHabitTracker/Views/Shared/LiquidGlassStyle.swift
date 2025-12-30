//
//  LiquidGlassStyle.swift
//  WeatherHabitTracker
//
//  Native iOS 26 Liquid Glass support using system APIs.
//  Uses Apple's glassEffect modifier and system materials.
//

import SwiftUI

// MARK: - Native Liquid Glass View Modifier

/// A view modifier that applies native iOS 26 Liquid Glass effects.
/// Uses system `.glassEffect()` on iOS 26+ or falls back to materials on earlier versions.
struct NativeLiquidGlass: ViewModifier {
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            content
                .glassEffect(.regular.interactive(true), in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

extension View {
    /// Applies native iOS 26 Liquid Glass effect to the view.
    /// Uses system `.glassEffect()` API when available.
    func liquidGlass(cornerRadius: CGFloat = 24) -> some View {
        self.modifier(NativeLiquidGlass(cornerRadius: cornerRadius))
    }
    
    /// Applies glass effect with prominent styling for important actions.
    @ViewBuilder
    func liquidGlassProminent(cornerRadius: CGFloat = 24) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.glassEffect(.regular.tint(.accentColor), in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.thinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

// MARK: - Liquid Glass Background

/// A background view optimized for Liquid Glass content.
/// Provides a subtle gradient that works well with translucent materials.
struct LiquidGlassBackground: View {
    var style: BackgroundStyle = .default
    
    enum BackgroundStyle {
        case `default`
        case weather
        case habits
    }
    
    var body: some View {
        switch style {
        case .default:
            defaultBackground
        case .weather:
            weatherBackground
        case .habits:
            habitsBackground
        }
    }
    
    private var defaultBackground: some View {
        #if os(iOS)
        MeshGradient(
            width: 3,
            height: 3,
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
            colors: [
                Color(nsColor: .windowBackgroundColor),
                Color(nsColor: .controlBackgroundColor)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        #endif
    }
    
    private var weatherBackground: some View {
        MeshGradient(
            width: 3,
            height: 3,
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
            width: 3,
            height: 3,
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

// MARK: - Concentric Shape Support

extension View {
    /// Creates a concentric rounded rectangle shape that aligns with container curvature.
    /// Uses iOS 26's ConcentricRectangle when available.
    @ViewBuilder
    func concentricClipShape(cornerRadius: CGFloat = 20) -> some View {
        if #available(iOS 26.0, macOS 26.0, *) {
            self.clipShape(ConcentricRectangle())
        } else {
            self.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}
