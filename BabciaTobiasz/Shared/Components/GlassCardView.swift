// GlassCardView.swift
// BabciaTobiasz

import SwiftUI

/// Glass-morphism card using Liquid Glass design
struct GlassCardView<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat?
    var showBorder: Bool = true
    var padding: CGFloat?
    @Environment(\.dsTheme) private var theme
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    init(cornerRadius: CGFloat? = nil, showBorder: Bool = true, padding: CGFloat? = nil, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        let resolvedCornerRadius = cornerRadius ?? theme.shape.cardCornerRadius
        let resolvedPadding = padding ?? theme.grid.cardPadding

        content
            .padding(resolvedPadding)
            .frame(maxWidth: .infinity)
            .liquidGlass(cornerRadius: resolvedCornerRadius)
            .overlay {
                if showBorder && theme.shape.borderWidth > 0 {
                    RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(theme.shape.borderOpacity), lineWidth: theme.shape.borderWidth)
                }
            }
    }
}

// MARK: - View Extensions

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat?
    var padding: CGFloat?

    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        let resolvedPadding = padding ?? theme.grid.cardPadding
        let resolvedCornerRadius = cornerRadius ?? theme.shape.cardCornerRadius

        content
            .padding(resolvedPadding)
            .frame(maxWidth: .infinity)
            .liquidGlass(cornerRadius: resolvedCornerRadius)
            .overlay {
                if theme.shape.borderWidth > 0 {
                    RoundedRectangle(cornerRadius: resolvedCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(theme.shape.borderOpacity), lineWidth: theme.shape.borderWidth)
                }
            }
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat? = nil, padding: CGFloat? = nil) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

// MARK: - Button Styles

struct NativeGlassButtonStyle: ButtonStyle {
    var isProminent: Bool = false
    @Environment(\.dsTheme) private var theme
    
    func makeBody(configuration: Configuration) -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            configuration.label
                .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                .padding(.vertical, theme.grid.buttonVerticalPadding)
                .glassEffect(isProminent ? .regular.interactive() : .regular, in: .capsule)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(theme.motion.pressSpring, value: configuration.isPressed)
        } else {
            fallbackButton(configuration)
        }
        #else
        fallbackButton(configuration)
        #endif
    }
    
    @ViewBuilder
    private func fallbackButton(_ configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
            .padding(.vertical, theme.grid.buttonVerticalPadding)
            .background(.ultraThinMaterial, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.motion.pressSpring, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == NativeGlassButtonStyle {
    static var nativeGlass: NativeGlassButtonStyle { NativeGlassButtonStyle() }
    static var nativeGlassProminent: NativeGlassButtonStyle { NativeGlassButtonStyle(isProminent: true) }
}

struct GlassButtonStyle: ButtonStyle {
    var color: Color = .appAccent
    var isProminent: Bool = false
    @Environment(\.dsTheme) private var theme
    
    func makeBody(configuration: Configuration) -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            configuration.label
                .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                .padding(.vertical, theme.grid.buttonVerticalPadding)
                .glassEffect(isProminent ? .regular.interactive() : .regular, in: .capsule)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(theme.motion.pressSpring, value: configuration.isPressed)
        } else {
            fallbackButton(configuration)
        }
        #else
        fallbackButton(configuration)
        #endif
    }
    
    @ViewBuilder
    private func fallbackButton(_ configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
            .padding(.vertical, theme.grid.buttonVerticalPadding)
            .background(isProminent ? AnyShapeStyle(color.gradient) : AnyShapeStyle(.ultraThinMaterial))
            .foregroundStyle(isProminent ? .white : .primary)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(theme.motion.pressSpring, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle { GlassButtonStyle() }
    static func glass(color: Color, prominent: Bool = false) -> GlassButtonStyle {
        GlassButtonStyle(color: color, isProminent: prominent)
    }
}

#Preview("Glass Cards") {
    ScrollView {
        VStack(spacing: 20) {
            GlassCardView {
                VStack(spacing: 12) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.yellow)
                    Text(String(localized: "preview.glassCard.title"))
                        .dsFont(.headline)
                }
            }
            
            Button(String(localized: "preview.glassCard.button")) {}
                .buttonStyle(.nativeGlass)
            
            Button(String(localized: "preview.glassCard.prominent")) {}
                .buttonStyle(.nativeGlassProminent)
        }
        .padding()
    }
    .background(LiquidGlassBackground())
}
