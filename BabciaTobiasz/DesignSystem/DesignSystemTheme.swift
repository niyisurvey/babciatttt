//
//  DesignSystemTheme.swift
//  BabciaTobiasz
//
//  Central design system tokens and theme injection.
//

import SwiftUI

struct DesignSystemTheme {
    var palette: DSPalette
    var gradients: DSGradients
    var typography: DSTypography
    var motion: DSMotion
    var shape: DSShape
    var grid: DSGrid
    var glass: DSGlass
    var elevation: DSElevation
}

struct DSPalette {
    var primary: Color
    var secondary: Color
    var tertiary: Color
    var success: Color
    var warning: Color
    var error: Color
    var glassTint: Color
    var coolAccent: Color
    var warmAccent: Color

    // Semantic surface/text tokens
    var onPrimary: Color       // Content color on primary surfaces (typically white)
    var textSecondary: Color   // Secondary text (replaces .secondary)
    var neutral: Color         // Neutral color for shadows/overlays
}

struct DSGradients {
    var backgroundDefault: [Color]
    var backgroundWeather: [Color]
    var backgroundAreas: [Color]
    var splash: [Color]
    var areasProgress: [Color]
    var sunrise: [Color]
    var day: [Color]
    var sunset: [Color]
    var night: [Color]
}

struct DSShape {
    var cardCornerRadius: CGFloat
    var glassCornerRadius: CGFloat
    var subtleCornerRadius: CGFloat
    var tooltipCornerRadius: CGFloat
    var heroCornerRadius: CGFloat
    var controlCornerRadius: CGFloat
    var borderWidth: CGFloat
    var borderOpacity: Double
}

struct DSGrid {
    var cardPadding: CGFloat
    var cardPaddingTight: CGFloat
    var sectionSpacing: CGFloat
    var listSpacing: CGFloat
    var buttonMinHeight: CGFloat
    var buttonHorizontalPadding: CGFloat
    var buttonVerticalPadding: CGFloat
    var iconTiny: CGFloat
    var iconSmall: CGFloat
    var iconTitle2: CGFloat
    var iconTitle3: CGFloat
    var iconMedium: CGFloat
    var iconLarge: CGFloat
    var iconSplashSecondary: CGFloat
    var iconError: CGFloat
    var iconXL: CGFloat
    var iconXXL: CGFloat
    var iconXXXL: CGFloat
    var ringSize: CGFloat
    var detailCardHeightSmall: CGFloat
    var detailCardHeightLarge: CGFloat
    var heroHeaderCollapsedHeight: CGFloat
    var heroCardWidth: CGFloat
    var heroCardHeight: CGFloat
    var pierogiSize: CGFloat
    var pierogiEmojiScale: CGFloat
    var pierogiPotSize: CGFloat
    var pierogiPotGrowStep: CGFloat
}

enum DSGlassStrength {
    case ultraThin
    case thin
    case regular
    case thick

    var fallbackMaterial: Material {
        switch self {
        case .ultraThin: return .ultraThinMaterial
        case .thin: return .thinMaterial
        case .regular: return .regularMaterial
        case .thick: return .thickMaterial
        }
    }
}

/// Controls the visual style of glass effects across the app.
/// Use `.clear` for transparent, background-sampling glass.
/// Use `.regular` for more opaque, frosted glass.
enum DSGlassEffectStyle {
    case clear
    case regular
}

// MARK: - Glass Context System

/// Defines the context in which glass elements appear.
/// Each context can have independent settings for mesh opacity, native glass, etc.
enum DSGlassContext: String, CaseIterable {
    case mainView      // Tab views, primary screens (Home, Areas, Gallery, Settings)
    case sheet         // Modal sheets
    case detailView    // Detail/drill-down views
    case card          // Glass cards within views
    case overlay       // Floating elements (toasts, tooltips)
}

/// Per-context glass settings
struct DSGlassContextSettings {
    var meshOpacity: Double           // 0.0 = no mesh, 1.0 = full opacity
    var usesNativeGlass: Bool         // Use iOS 26+ native glass presentation
    var effectStyle: DSGlassEffectStyle

    static let defaultMainView = DSGlassContextSettings(
        meshOpacity: 0.08,
        usesNativeGlass: false,
        effectStyle: .clear
    )

    static let defaultSheet = DSGlassContextSettings(
        meshOpacity: 0.06,
        usesNativeGlass: true,
        effectStyle: .clear
    )

    static let defaultDetailView = DSGlassContextSettings(
        meshOpacity: 0.05,
        usesNativeGlass: false,
        effectStyle: .clear
    )

    static let defaultCard = DSGlassContextSettings(
        meshOpacity: 0.0,
        usesNativeGlass: false,
        effectStyle: .clear
    )

    static let defaultOverlay = DSGlassContextSettings(
        meshOpacity: 0.0,
        usesNativeGlass: true,
        effectStyle: .clear
    )
}

// MARK: - Native iOS 26 Glass Bridging

#if compiler(>=6.0)
@available(iOS 26.0, macOS 26.0, *)
extension DSGlassEffectStyle {
    /// Bridges design token to native iOS 26 Glass type
    var nativeGlass: Glass {
        switch self {
        case .clear: return .clear
        case .regular: return .regular
        }
    }

    /// Interactive glass for touch targets
    var nativeGlassInteractive: Glass {
        nativeGlass.interactive()
    }

    /// Tinted glass with specified color and opacity
    func nativeGlassTinted(_ color: Color, opacity: Double) -> Glass {
        nativeGlass.tint(color.opacity(opacity))
    }

    /// Interactive tinted glass
    func nativeGlassTintedInteractive(_ color: Color, opacity: Double) -> Glass {
        nativeGlass.tint(color.opacity(opacity)).interactive()
    }
}
#endif

struct DSGlass {
    var strength: DSGlassStrength
    var prominentStrength: DSGlassStrength
    var effectStyle: DSGlassEffectStyle
    var tintOpacity: Double
    var glowOpacityHigh: Double
    var glowOpacityLow: Double

    /// Per-context settings for grouped control
    var contextSettings: [DSGlassContext: DSGlassContextSettings]

    /// Get settings for a specific context, with fallback to defaults
    func settings(for context: DSGlassContext) -> DSGlassContextSettings {
        if let settings = contextSettings[context] {
            return settings
        }
        // Fallback defaults
        switch context {
        case .mainView: return .defaultMainView
        case .sheet: return .defaultSheet
        case .detailView: return .defaultDetailView
        case .card: return .defaultCard
        case .overlay: return .defaultOverlay
        }
    }
}

// MARK: - Elevation System

/// Shadow preset defining a complete shadow configuration
struct DSShadowPreset {
    var color: Color
    var opacity: Double
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat

    /// Applies this shadow preset to a view
    func apply<T: View>(to view: T) -> some View {
        view.shadow(color: color.opacity(opacity), radius: radius, x: x, y: y)
    }
}

/// Elevation system for consistent shadows and overlays
struct DSElevation {
    /// Small elevation - subtle lift (e.g., buttons, small cards)
    var level1: DSShadowPreset

    /// Medium elevation - standard cards and containers
    var level2: DSShadowPreset

    /// High elevation - modals, floating elements
    var level3: DSShadowPreset

    /// Overlay/scrim dim opacity
    var overlayDim: Double

    /// Shimmer effect opacity (loading states)
    var shimmerOpacity: Double
}

enum DSMotionPreset: String, CaseIterable {
    case slow
    case normal
    case fast

    var multiplier: Double {
        switch self {
        case .slow: return 1.25
        case .normal: return 1.0
        case .fast: return 0.85
        }
    }
}

struct DSMotion {
    var preset: DSMotionPreset

    private func scale(_ value: Double) -> Double {
        value * preset.multiplier
    }

    var pressSpring: Animation {
        .spring(response: scale(0.3))
    }

    var toggleSpring: Animation {
        .spring(response: scale(0.3), dampingFraction: 0.6)
    }

    var listSpring: Animation {
        .spring(response: scale(0.4))
    }

    var statsSpring: Animation {
        .spring(duration: scale(0.5))
    }

    var launchSpring: Animation {
        .spring(response: scale(0.6), dampingFraction: 0.7)
    }

    var fadeStandard: Animation {
        .easeInOut(duration: scale(0.5))
    }

    var fadeFast: Animation {
        .easeOut(duration: scale(0.3))
    }

    var shimmerDuration: Double { scale(1.2) }
    var shimmerLongDuration: Double { scale(1.5) }
    var spinnerDuration: Double { scale(1.0) }
    var meshAnimationInterval: Double { scale(3.0) }
}

enum DSFontWeight {
    case regular
    case semibold
    case bold
}

struct DSFontFamily {
    var regular: String
    var bold: String
    var italic: String
    var boldItalic: String

    func name(weight: DSFontWeight, italic isItalic: Bool) -> String {
        switch (weight, isItalic) {
        case (.regular, false): return regular
        case (.semibold, false): return bold
        case (.bold, false): return bold
        case (.regular, true): return italic
        case (.semibold, true): return boldItalic
        case (.bold, true): return boldItalic
        }
    }
}

enum DSTextStyle: CaseIterable {
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case subheadline
    case body
    case caption
    case caption2

    var size: CGFloat {
        switch self {
        case .largeTitle: return 34
        case .title: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .subheadline: return 15
        case .body: return 17
        case .caption: return 12
        case .caption2: return 11
        }
    }

    var relativeTo: Font.TextStyle {
        switch self {
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .subheadline: return .subheadline
        case .body: return .body
        case .caption: return .caption
        case .caption2: return .caption2
        }
    }
}

struct DSTypography {
    var family: DSFontFamily

    func font(_ style: DSTextStyle, weight: DSFontWeight = .regular, italic: Bool = false) -> Font {
        Font.custom(family.name(weight: weight, italic: italic), size: style.size, relativeTo: style.relativeTo)
    }

    func custom(size: CGFloat, weight: DSFontWeight = .regular, italic: Bool = false) -> Font {
        Font.custom(family.name(weight: weight, italic: italic), size: size)
    }
}

extension DesignSystemTheme {
    static let `default` = DesignSystemTheme(
        palette: DSPalette(
            primary: .appAccent,
            secondary: .purple,
            tertiary: .cyan,
            success: .appSuccess,
            warning: .appWarning,
            error: .appError,
            glassTint: .white,
            coolAccent: .teal,
            warmAccent: .orange,
            onPrimary: .white,
            textSecondary: Color(.secondaryLabel),
            neutral: .black
        ),
        gradients: DSGradients(
            backgroundDefault: [
                .blue, .cyan, .teal,
                .purple, .blue, .cyan,
                .indigo, .purple, .blue
            ],
            backgroundWeather: [
                Color(red: 0.4, green: 0.7, blue: 0.9), Color(red: 0.5, green: 0.8, blue: 0.95), Color(red: 0.6, green: 0.85, blue: 1.0),
                Color(red: 0.5, green: 0.75, blue: 0.9), Color(red: 0.55, green: 0.8, blue: 0.92), Color(red: 0.6, green: 0.82, blue: 0.95),
                Color(red: 0.5, green: 0.7, blue: 0.85), Color(red: 0.55, green: 0.75, blue: 0.88), Color(red: 0.6, green: 0.78, blue: 0.9)
            ],
            backgroundAreas: [
                .green, .teal, .cyan,
                .mint, .green, .teal,
                .teal, .mint, .green
            ],
            splash: [
                .blue.opacity(0.3), .purple.opacity(0.2), .cyan.opacity(0.3)
            ],
            areasProgress: [
                .green, .teal
            ],
            sunrise: Color.sunriseGradient,
            day: Color.dayGradient,
            sunset: Color.sunsetGradient,
            night: Color.nightGradient
        ),
        typography: DSTypography(
            family: DSFontFamily(
                regular: "LinLibertine",
                bold: "LinLibertineB",
                italic: "LinLibertineI",
                boldItalic: "LinLibertineBI"
            )
        ),
        motion: DSMotion(preset: .normal),
        shape: DSShape(
            cardCornerRadius: 20,
            glassCornerRadius: 24,
            subtleCornerRadius: 12,
            tooltipCornerRadius: 16,
            heroCornerRadius: 70,
            controlCornerRadius: 16,
            borderWidth: 0,
            borderOpacity: 0.0
        ),
        grid: DSGrid(
            cardPadding: 16,
            cardPaddingTight: 12,
            sectionSpacing: 20,
            listSpacing: 12,
            buttonMinHeight: 48,
            buttonHorizontalPadding: 24,
            buttonVerticalPadding: 12,
            iconTiny: 12,
            iconSmall: 20,
            iconTitle2: 22,
            iconTitle3: 20,
            iconMedium: 32,
            iconLarge: 44,
            iconSplashSecondary: 40,
            iconError: 50,
            iconXL: 60,
            iconXXL: 80,
            iconXXXL: 110,
            ringSize: 100,
            detailCardHeightSmall: 120,
            detailCardHeightLarge: 150,
            heroHeaderCollapsedHeight: 120,
            heroCardWidth: 260,
            heroCardHeight: 260,
            pierogiSize: 60,
            pierogiEmojiScale: 2.2,
            pierogiPotSize: 140,
            pierogiPotGrowStep: 6
        ),
        glass: DSGlass(
            strength: .regular,
            prominentStrength: .thin,
            effectStyle: .clear,
            tintOpacity: 0.02,
            glowOpacityHigh: 0.7,
            glowOpacityLow: 0.2,
            contextSettings: [
                .mainView: .defaultMainView,
                .sheet: .defaultSheet,
                .detailView: .defaultDetailView,
                .card: .defaultCard,
                .overlay: .defaultOverlay
            ]
        ),
        elevation: DSElevation(
            level1: DSShadowPreset(color: .black, opacity: 0.08, radius: 4, x: 0, y: 2),
            level2: DSShadowPreset(color: .black, opacity: 0.12, radius: 10, x: 0, y: 4),
            level3: DSShadowPreset(color: .black, opacity: 0.15, radius: 20, x: 0, y: 10),
            overlayDim: 0.4,
            shimmerOpacity: 0.3
        )
    )
}

private struct DesignSystemThemeKey: EnvironmentKey {
    static let defaultValue = DesignSystemTheme.default
}

private struct GlassContextKey: EnvironmentKey {
    static let defaultValue: DSGlassContext = .mainView
}

extension EnvironmentValues {
    var dsTheme: DesignSystemTheme {
        get { self[DesignSystemThemeKey.self] }
        set { self[DesignSystemThemeKey.self] = newValue }
    }

    var glassContext: DSGlassContext {
        get { self[GlassContextKey.self] }
        set { self[GlassContextKey.self] = newValue }
    }
}

struct DSFontModifier: ViewModifier {
    let style: DSTextStyle
    let weight: DSFontWeight
    let italic: Bool

    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        content.font(theme.typography.font(style, weight: weight, italic: italic))
    }
}

extension View {
    func dsTheme(_ theme: DesignSystemTheme) -> some View {
        environment(\.dsTheme, theme)
    }

    func dsFont(_ style: DSTextStyle, weight: DSFontWeight = .regular, italic: Bool = false) -> some View {
        modifier(DSFontModifier(style: style, weight: weight, italic: italic))
    }

    /// Sets the glass context for this view and its descendants.
    /// Glass elements will automatically adapt their appearance based on context.
    func glassContext(_ context: DSGlassContext) -> some View {
        environment(\.glassContext, context)
    }
}

// MARK: - Elevation Modifier

enum DSElevationLevel {
    case level1, level2, level3
}

struct DSElevationModifier: ViewModifier {
    let level: DSElevationLevel
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        let preset: DSShadowPreset = {
            switch level {
            case .level1: return theme.elevation.level1
            case .level2: return theme.elevation.level2
            case .level3: return theme.elevation.level3
            }
        }()
        content.shadow(
            color: preset.color.opacity(preset.opacity),
            radius: preset.radius,
            x: preset.x,
            y: preset.y
        )
    }
}

extension View {
    /// Applies a design system elevation shadow
    func dsElevation(_ level: DSElevationLevel) -> some View {
        modifier(DSElevationModifier(level: level))
    }
}
