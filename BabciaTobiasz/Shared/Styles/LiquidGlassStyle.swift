// LiquidGlassStyle.swift
// BabciaTobiasz

import SwiftUI

// MARK: - Liquid Glass Modifier

/// Applies native iOS 26 Liquid Glass effects with fallback
struct NativeLiquidGlass: ViewModifier {
    var cornerRadius: CGFloat?
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        let resolvedCornerRadius = cornerRadius ?? theme.shape.glassCornerRadius
        #if compiler(>=6.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(
                theme.glass.effectStyle.nativeGlassInteractive,
                in: .rect(cornerRadius: resolvedCornerRadius)
            )
        } else {
            fallbackContent(content, cornerRadius: resolvedCornerRadius)
        }
        #else
        fallbackContent(content, cornerRadius: resolvedCornerRadius)
        #endif
    }

    @ViewBuilder
    private func fallbackContent(_ content: Content, cornerRadius: CGFloat) -> some View {
        content
            .background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct LiquidGlassProminentModifier: ViewModifier {
    var cornerRadius: CGFloat?
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        let resolvedCornerRadius = cornerRadius ?? theme.shape.glassCornerRadius
        #if compiler(>=6.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(
                theme.glass.effectStyle.nativeGlassTinted(theme.palette.primary, opacity: theme.glass.tintOpacity),
                in: .rect(cornerRadius: resolvedCornerRadius)
            )
        } else {
            content.background(theme.glass.prominentStrength.fallbackMaterial, in: RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
        }
        #else
        content.background(theme.glass.prominentStrength.fallbackMaterial, in: RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
        #endif
    }
}

struct SubtleGlassModifier: ViewModifier {
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        let resolvedCornerRadius = theme.shape.subtleCornerRadius
        #if compiler(>=6.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            content.glassEffect(
                theme.glass.effectStyle.nativeGlass,
                in: .rect(cornerRadius: resolvedCornerRadius)
            )
        } else {
            content.background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
        }
        #else
        content.background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous))
        #endif
    }
}

extension View {
    /// Applies Liquid Glass effect
    func liquidGlass(cornerRadius: CGFloat? = nil) -> some View {
        modifier(NativeLiquidGlass(cornerRadius: cornerRadius))
    }
    
    /// Prominent glass effect for buttons
    func liquidGlassProminent(cornerRadius: CGFloat? = nil) -> some View {
        modifier(LiquidGlassProminentModifier(cornerRadius: cornerRadius))
    }
    
    /// Subtle glass effect
    func subtleGlass() -> some View {
        modifier(SubtleGlassModifier())
    }
    
    /// Concentric clip shape for nested elements
    @ViewBuilder
    func concentricClipShape(cornerRadius: CGFloat = 20) -> some View {
        #if compiler(>=6.0)
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
    @Environment(\.dsTheme) private var theme
    @Environment(\.glassContext) private var context

    enum BackgroundStyle { case `default`, areas }

    /// Resolved mesh opacity from context settings
    private var meshOpacity: Double {
        theme.glass.settings(for: context).meshOpacity
    }

    var body: some View {
        // If meshOpacity is 0, don't render anything (pure native glass will sample through)
        if meshOpacity > 0 {
            switch style {
            case .default: defaultBackground
            case .areas: areasBackground
            }
        }
    }

    private var defaultBackground: some View {
        #if os(iOS)
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            MeshGradient(
                width: 3, height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: adjustedColors(theme.gradients.backgroundDefault)
            )
        }
        .ignoresSafeArea()
        #else
        LinearGradient(
            colors: [Color(nsColor: .windowBackgroundColor), Color(nsColor: .controlBackgroundColor)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()
        #endif
    }

    private var areasBackground: some View {
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            MeshGradient(
                width: 3, height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: adjustedColors(theme.gradients.backgroundAreas)
            )
        }
        .ignoresSafeArea()
    }

    /// Adjusts color opacity based on context's meshOpacity token
    private func adjustedColors(_ colors: [Color]) -> [Color] {
        colors.map { $0.opacity(meshOpacity) }
    }

    private func animatedMeshPoints(for date: Date) -> [SIMD2<Float>] {
        let time = Float(date.timeIntervalSince1970)
        let interval = Float(max(theme.motion.meshAnimationInterval, 0.1))
        let baseSpeed = 1.0 / interval
        let offset = sin(time * (baseSpeed * 0.5)) * 0.2
        let offset2 = cos(time * (baseSpeed * 0.35)) * 0.14
        return [
            [0.0, 0.0], [0.5 + offset2, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5 + offset, 0.5 - offset], [1.0, 0.5],
            [0.0, 1.0], [0.5 - offset2, 1.0], [1.0, 1.0]
        ]
    }
}

// MARK: - Sheet Presentation Helpers

struct LiquidGlassSheetBackgroundModifier: ViewModifier {
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        let settings = theme.glass.settings(for: .sheet)

        // iOS 26 sheets are native glass by default when usesNativeGlass is true
        // We just need to ensure no custom background blocks it
        if settings.usesNativeGlass {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

extension View {
    /// Applies native glass background to a sheet presentation.
    /// Respects the `sheetUsesNativeGlass` token.
    func liquidGlassSheetBackground() -> some View {
        modifier(LiquidGlassSheetBackgroundModifier())
            .glassContext(.sheet)
    }

    /// Convenience wrapper for presenting a sheet with glass context and background.
    func liquidGlassSheet<Content: View>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.sheet(isPresented: isPresented, onDismiss: onDismiss) {
            content()
                .liquidGlassSheetBackground()
        }
    }

    /// Convenience wrapper for presenting a sheet with item binding.
    func liquidGlassSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        self.sheet(item: item, onDismiss: onDismiss) { item in
            content(item)
                .liquidGlassSheetBackground()
        }
    }
}
