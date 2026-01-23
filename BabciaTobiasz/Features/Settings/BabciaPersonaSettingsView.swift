//
//  BabciaPersonaSettingsView.swift
//  BabciaTobiasz
//

import SwiftUI

struct BabciaPersonaSettingsView: View {
    @AppStorage("primaryPersonaRaw") private var primaryPersonaRaw: String = BabciaPersona.classic.rawValue
    @State private var selectedPersona: BabciaPersona = .classic
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerSection
                    BabciaPersonaSelectionView(selectedPersona: $selectedPersona)
                }
                .padding(.horizontal, theme.grid.cardPadding)
                .padding(.vertical, theme.grid.sectionSpacing)
            }
        }
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String(localized: "settings.babcia.selection.title"))
                    .dsFont(.headline, weight: .bold)
                    .lineLimit(1)
            }
        }
        .onAppear {
            selectedPersona = BabciaPersona(rawValue: primaryPersonaRaw) ?? .classic
        }
        .onChange(of: selectedPersona) { _, newValue in
            primaryPersonaRaw = newValue.rawValue
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(String(localized: "settings.babcia.title"))
                .dsFont(.title2, weight: .bold)
            Text(String(localized: "settings.babcia.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }
}

#Preview {
    NavigationStack {
        BabciaPersonaSettingsView()
    }
    .dsTheme(.default)
}
