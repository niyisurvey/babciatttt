// FeatureTooltip.swift
// BabciaTobiasz

import SwiftUI

/// Tooltip popup for feature descriptions
struct FeatureTooltip: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isVisible: Bool
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: theme.grid.iconSmall))
                    .foregroundStyle(theme.palette.primary)
                
                Text(title)
                    .dsFont(.headline, weight: .bold)
                
                Spacer()
                
                Button {
                    withAnimation(theme.motion.pressSpring) {
                        isVisible = false
                    }
                    hapticFeedback(.light)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(description)
                .dsFont(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: 300)
        .liquidGlass(cornerRadius: theme.shape.tooltipCornerRadius)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

/// Modifier for adding info button with tooltip
struct TooltipModifier: ViewModifier {
    let title: String
    let description: String
    let icon: String
    @State private var showTooltip = false
    @Environment(\.dsTheme) private var theme
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Button {
                    withAnimation(theme.motion.pressSpring) {
                        showTooltip.toggle()
                    }
                    hapticFeedback(.light)
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: theme.grid.iconTiny))
                        .foregroundStyle(.secondary)
                }
                .offset(x: 8, y: -8)
            }
            .overlay {
                if showTooltip {
                    FeatureTooltip(
                        title: title,
                        description: description,
                        icon: icon,
                        isVisible: $showTooltip
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
    }
}

extension View {
    /// Adds a tooltip info button to the view
    func featureTooltip(title: String, description: String, icon: String = "lightbulb.fill") -> some View {
        modifier(TooltipModifier(title: title, description: description, icon: icon))
    }
}

/// Haptic feedback utility
func hapticFeedback(_ style: HapticStyle) {
    #if os(iOS)
    switch style {
    case .light:
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    case .medium:
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    case .heavy:
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    case .success:
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    case .warning:
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    case .error:
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    case .selection:
        UISelectionFeedbackGenerator().selectionChanged()
    }
    #endif
}

enum HapticStyle {
    case light, medium, heavy, success, warning, error, selection
}

#Preview {
    VStack(spacing: 40) {
        Text("Weather Card")
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .featureTooltip(
                title: "Weather Updates",
                description: "Real-time weather data updates every 30 minutes automatically.",
                icon: "cloud.sun.fill"
            )
        
        FeatureTooltip(
            title: "Smart Insights",
            description: "Get personalized suggestions based on weather conditions to plan your daily areas.",
            icon: "sparkles",
            isVisible: .constant(true)
        )
    }
    .padding()
}
