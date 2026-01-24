//
//  ErrorView.swift
//  BabciaTobiasz
//
//  A reusable error display component with retry functionality.
//  Provides consistent error handling UI across the app.
//

import SwiftUI

/// A view for displaying error states with an optional retry action.
/// Uses glass styling and provides clear user feedback.
struct ErrorView: View {
    
    // MARK: - Properties
    
    /// The error title
    var title: String = String(localized: "errorView.default.title")
    
    /// The error message/description
    var message: String
    
    /// SF Symbol name for the error icon
    var iconName: String = "exclamationmark.triangle.fill"
    
    /// Icon color (defaults to theme.palette.warning if nil)
    var iconColor: Color?

    /// Optional retry action
    var retryAction: (() -> Void)?

    /// Optional dismiss action
    var dismissAction: (() -> Void)?
    @Environment(\.dsTheme) private var theme

    private var resolvedIconColor: Color {
        iconColor ?? theme.palette.warning
    }
    
    // MARK: - Body
    
    var body: some View {
        GlassCardView {
            VStack(spacing: 20) {
                // Error icon
                Image(systemName: iconName)
                    .font(.system(size: theme.grid.iconError))
                    .foregroundStyle(resolvedIconColor)
                    .symbolEffect(.pulse)
                
                // Error text
                VStack(spacing: 8) {
                    Text(title)
                        .dsFont(.headline, weight: .bold)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .dsFont(.subheadline)
                        .foregroundStyle(theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Action buttons
                actionButtons
            }
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Action Buttons
    
    /// Retry and dismiss buttons
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Dismiss button (if provided)
            if let dismissAction = dismissAction {
                Button {
                    dismissAction()
                } label: {
                    Text(String(localized: "common.dismiss"))
                        .dsFont(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
            
            // Retry button (if provided)
            if let retryAction = retryAction {
                Button {
                    retryAction()
                } label: {
                    Label(String(localized: "common.retry"), systemImage: "arrow.clockwise")
                        .dsFont(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass(color: theme.palette.primary, prominent: true))
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Error Types

/// Common error display configurations
extension ErrorView {
    /// Creates an error view for network errors (uses theme.palette.error)
    static func networkError(
        message: String = String(localized: "errorView.network.message"),
        retryAction: @escaping () -> Void
    ) -> ErrorView {
        ErrorView(
            title: String(localized: "errorView.network.title"),
            message: message,
            iconName: "wifi.exclamationmark",
            iconColor: .appError,
            retryAction: retryAction
        )
    }

    /// Creates an error view for location errors (uses theme.palette.warning)
    static func locationError(
        message: String = String(localized: "errorView.location.message"),
        retryAction: (() -> Void)? = nil
    ) -> ErrorView {
        ErrorView(
            title: String(localized: "errorView.location.title"),
            message: message,
            iconName: "location.slash.fill",
            iconColor: nil, // Uses default warning from theme
            retryAction: retryAction
        )
    }

    /// Creates an error view for data loading errors (uses neutral color)
    static func dataError(
        message: String = String(localized: "errorView.data.message"),
        retryAction: @escaping () -> Void
    ) -> ErrorView {
        ErrorView(
            title: String(localized: "errorView.data.title"),
            message: message,
            iconName: "exclamationmark.icloud.fill",
            iconColor: Color(.secondaryLabel),
            retryAction: retryAction
        )
    }
    
    /// Creates an error view for permission errors
    static func permissionError(
        title: String = String(localized: "errorView.permission.title"),
        message: String,
        settingsAction: @escaping () -> Void
    ) -> some View {
        PermissionErrorCard(title: title, message: message, settingsAction: settingsAction)
    }
}

private struct PermissionErrorCard: View {
    let title: String
    let message: String
    let settingsAction: () -> Void

    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: theme.grid.iconError))
                    .foregroundStyle(theme.palette.warning)

                VStack(spacing: 8) {
                    Text(title)
                        .dsFont(.headline, weight: .bold)

                    Text(message)
                        .dsFont(.subheadline)
                        .foregroundStyle(theme.palette.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Button {
                    settingsAction()
                } label: {
                    Label(String(localized: "common.openSettings"), systemImage: "gear")
                        .dsFont(.headline)
                }
                .buttonStyle(.glass(color: theme.palette.primary, prominent: true))
            }
            .padding(.vertical, 12)
        }
    }
}

// MARK: - Inline Error Banner

/// A compact inline error banner for non-blocking errors
struct ErrorBanner: View {
    
    // MARK: - Properties
    
    var message: String
    var dismissAction: (() -> Void)?
    @Environment(\.dsTheme) private var theme
    
    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(theme.palette.warning)

            Text(message)
                .dsFont(.subheadline)
                .lineLimit(2)

            Spacer()

            if let dismissAction = dismissAction {
                Button {
                    dismissAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.palette.textSecondary)
                }
            }
        }
        .padding()
        .background(theme.palette.warning.opacity(0.1), in: RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius)
                .stroke(theme.palette.warning.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Error View Modifier

extension View {
    /// Shows an error overlay when an error occurs
    /// - Parameters:
    ///   - error: Binding to the optional error message
    ///   - retryAction: Action to perform when retry is tapped
    /// - Returns: The view with error overlay capability
    func errorOverlay(
        error: Binding<String?>,
        retryAction: @escaping () -> Void
    ) -> some View {
        modifier(ErrorOverlayModifier(error: error, retryAction: retryAction))
    }
}

struct ErrorOverlayModifier: ViewModifier {
    @Binding var error: String?
    let retryAction: () -> Void
    @Environment(\.dsTheme) private var theme

    func body(content: Content) -> some View {
        content
            .overlay {
                if let errorMessage = error {
                    ZStack {
                        theme.palette.neutral.opacity(theme.elevation.overlayDim)
                            .ignoresSafeArea()

                        ErrorView(
                            message: errorMessage,
                            retryAction: retryAction,
                            dismissAction: { error = nil }
                        )
                        .padding()
                    }
                    .transition(.opacity)
                }
            }
            .animation(theme.motion.fadeStandard, value: error != nil)
    }
}

// MARK: - Preview

#Preview("Error Views") {
    ScrollView {
        VStack(spacing: 24) {
            // Default error
            ErrorView(
                message: String(localized: "errorView.preview.unexpected"),
                retryAction: {}
            )
            
            // Network error
            ErrorView.networkError {
            }
            
            // Location error
            ErrorView.locationError()
            
            // Error banner
            ErrorBanner(message: String(localized: "errorView.preview.sync")) {
            }
        }
        .padding()
    }
    .background(Color.gray.opacity(0.1))
}
