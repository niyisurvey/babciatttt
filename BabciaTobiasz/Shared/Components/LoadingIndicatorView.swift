//
//  LoadingIndicatorView.swift
//  BabciaTobiasz
//
//  A reusable loading indicator component with optional message.
//  Uses smooth animations and integrates with the app's glass design.
//

import SwiftUI

/// A loading indicator view with optional message and glass styling.
/// Can be used as an overlay or inline component.
struct LoadingIndicatorView: View {
    
    // MARK: - Properties
    
    /// Optional message to display below the spinner
    var message: String?
    
    /// Size of the spinner
    var size: SpinnerSize = .medium
    
    /// Whether to show a glass background
    var showBackground: Bool = true
    @Environment(\.dsTheme) private var theme
    
    // MARK: - Spinner Sizes
    
    enum SpinnerSize {
        case small
        case medium
        case large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 20
            case .medium: return 40
            case .large: return 60
            }
        }
        
        var strokeWidth: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 3
            case .large: return 4
            }
        }
        
        var font: Font {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .headline
            }
        }

        var textStyle: DSTextStyle {
            switch self {
            case .small: return .caption
            case .medium: return .subheadline
            case .large: return .headline
            }
        }
    }
    
    // MARK: - State
    
    @State private var isAnimating = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            // Custom spinner
            customSpinner
            
            // Optional message
            if let message = message {
                Text(message)
                    .dsFont(size.textStyle)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(showBackground ? 32 : 0)
        .background {
            if showBackground {
                RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius)
                    .fill(theme.glass.strength.fallbackMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    // MARK: - Custom Spinner
    
    /// Animated circular spinner
    private var customSpinner: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(.quaternary, lineWidth: size.strokeWidth)
                .frame(width: size.dimension, height: size.dimension)
            
            // Animated arc
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(
                        colors: [theme.palette.primary, theme.palette.secondary, theme.palette.primary],
                        center: .center
                    ),
                    style: StrokeStyle(
                        lineWidth: size.strokeWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size.dimension, height: size.dimension)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: theme.motion.spinnerDuration)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
    }
}

// MARK: - Full Screen Loading Overlay

/// A full-screen loading overlay with blur background
struct LoadingOverlay: View {
    
    // MARK: - Properties
    
    /// Message to display
    var message: String = String(localized: "loading.default")
    
    /// Whether the overlay is visible
    @Binding var isLoading: Bool
    
    // MARK: - Body
    
    var body: some View {
        if isLoading {
            ZStack {
                // Blur background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                // Loading indicator
                LoadingIndicatorView(message: message, size: .large)
            }
            .transition(.opacity)
        }
    }
}

// MARK: - Shimmer Loading Effect

/// A shimmer effect for loading placeholders
struct ShimmerView: View {
    
    // MARK: - State
    
    @State private var isAnimating = false
    @Environment(\.dsTheme) private var theme
    
    // MARK: - Body
    
    var body: some View {
        LinearGradient(
            colors: [
                .gray.opacity(0.3),
                .gray.opacity(0.1),
                .gray.opacity(0.3)
            ],
            startPoint: isAnimating ? .leading : .trailing,
            endPoint: isAnimating ? .trailing : .leading
        )
        .onAppear {
            withAnimation(
                .linear(duration: theme.motion.shimmerLongDuration)
                .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Shimmer Modifier

extension View {
    /// Applies a shimmer loading effect to the view
    /// - Parameter isLoading: Whether to show the shimmer effect
    /// - Returns: The modified view
    func shimmer(isLoading: Bool) -> some View {
        self
            .redacted(reason: isLoading ? .placeholder : [])
            .overlay {
                if isLoading {
                    ShimmerView()
                        .mask(self)
                }
            }
    }
}

// MARK: - Preview

#Preview("Loading Indicators") {
    VStack(spacing: 40) {
        // Different sizes
        HStack(spacing: 40) {
            LoadingIndicatorView(size: .small, showBackground: false)
            LoadingIndicatorView(size: .medium, showBackground: false)
            LoadingIndicatorView(size: .large, showBackground: false)
        }
        
        // With message
        LoadingIndicatorView(message: String(localized: "loading.fetching"), size: .medium)
        
        // Without background
        LoadingIndicatorView(message: String(localized: "loading.default"), size: .small, showBackground: false)
        
        // Shimmer placeholder
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .frame(height: 20)
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 200, height: 16)
        }
        .shimmer(isLoading: true)
        .frame(width: 300)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
