// GlassCardView.swift
// WeatherHabitTracker

import SwiftUI

/// Glass-morphism card using Liquid Glass design
struct GlassCardView<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var showBorder: Bool = true
    var padding: CGFloat = 16
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    init(cornerRadius: CGFloat = 20, showBorder: Bool = true, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.showBorder = showBorder
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity)
            .liquidGlass(cornerRadius: cornerRadius)
    }
}

// MARK: - View Extensions

extension View {
    func glassCard(cornerRadius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity)
            .liquidGlass(cornerRadius: cornerRadius)
    }
}

// MARK: - Button Styles

struct NativeGlassButtonStyle: ButtonStyle {
    var isProminent: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            configuration.label
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .glassEffect(isProminent ? .regular.interactive() : .regular, in: .capsule)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
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
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == NativeGlassButtonStyle {
    static var nativeGlass: NativeGlassButtonStyle { NativeGlassButtonStyle() }
    static var nativeGlassProminent: NativeGlassButtonStyle { NativeGlassButtonStyle(isProminent: true) }
}

struct GlassButtonStyle: ButtonStyle {
    var color: Color = .blue
    var isProminent: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        #if compiler(>=7.0)
        if #available(iOS 26.0, macOS 26.0, *) {
            configuration.label
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .glassEffect(isProminent ? .regular.interactive() : .regular, in: .capsule)
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.spring(response: 0.3), value: configuration.isPressed)
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
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(isProminent ? AnyShapeStyle(color.gradient) : AnyShapeStyle(.ultraThinMaterial))
            .foregroundStyle(isProminent ? .white : .primary)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
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
                    Text("Glass Card")
                        .font(.headline)
                }
            }
            
            Button("Glass Button") {}
                .buttonStyle(.nativeGlass)
            
            Button("Prominent Button") {}
                .buttonStyle(.nativeGlassProminent)
        }
        .padding()
    }
    .background(LiquidGlassBackground())
}
