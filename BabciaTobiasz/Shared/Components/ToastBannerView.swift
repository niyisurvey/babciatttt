//
//  ToastBannerView.swift
//  BabciaTobiasz
//
//  Lightweight toast banner for transient confirmations and undo actions.
//

import SwiftUI

struct ToastBannerView: View {
    let message: String
    let actionTitle: String?
    let onAction: (() -> Void)?
    let onDismiss: (() -> Void)?

    @Environment(\.dsTheme) private var theme

    var body: some View {
        HStack(spacing: theme.grid.listSpacing) {
            Text(message)
                .dsFont(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer()

            if let actionTitle, let onAction {
                Button(actionTitle) {
                    onAction()
                }
                .dsFont(.subheadline, weight: .bold)
                .buttonStyle(.nativeGlass)
            }

            if let onDismiss {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "common.dismiss"))
            }
        }
        .padding(.vertical, theme.grid.cardPaddingTight)
        .padding(.horizontal, theme.grid.cardPadding)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(theme.palette.glassTint.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: theme.palette.glassTint.opacity(0.2), radius: theme.grid.iconTiny)
    }
}

#Preview {
    VStack(spacing: 20) {
        ToastBannerView(message: "Task completed.", actionTitle: "Undo", onAction: {}, onDismiss: {})
        ToastBannerView(message: "Reminders saved.", actionTitle: nil, onAction: nil, onDismiss: {})
    }
    .padding()
    .dsTheme(.default)
    .background(Color.gray.opacity(0.1))
}
