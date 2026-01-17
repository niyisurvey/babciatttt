import SwiftUI

struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.3), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 10)
    }
}

extension View {
    func glass() -> some View {
        modifier(GlassModifier())
    }
}
