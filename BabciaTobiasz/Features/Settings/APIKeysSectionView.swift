//
//  APIKeysSectionView.swift
//  BabciaTobiasz
//
//  Settings section for API key management.
//

import SwiftUI

struct APIKeysSectionView: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Text("API Keys")
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            VStack(spacing: theme.grid.listSpacing) {
                DreamAPIKeyCardView()
                GeminiAPIKeyCardView()
            }
        }
    }
}
