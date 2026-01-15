// ButtonsShowcaseView.swift
// BabciaTobiasz
// Added 2026-01-15 08:10 GMT

import SwiftUI

struct ButtonsShowcaseView: View {
    @Environment(\.dsTheme) private var theme
    @State private var showClearSheet = false
    @State private var showRegularSheet = false
    @State private var showTintedSheet = false

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerSection
                    glassEffectsButtonsSection
                    glassCardsSection
                    glassSheetSection
                }
                .padding()
            }
        }
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Liquid Glass Lab")
                    .dsFont(.title2, weight: .bold)
                    .lineLimit(1)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Liquid Glass Lab")
                .dsFont(.title2, weight: .bold)
            Text("Glass effects for buttons, cards, and sheets.")
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var glassEffectsButtonsSection: some View {
        section(title: "Glass Effects (Buttons)") {
            if #available(iOS 26.0, *) {
                VStack(spacing: theme.grid.listSpacing) {
                    buttonRow(title: "Regular") {
                        Button("Regular") {}
                            .dsFont(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                            .padding(.vertical, theme.grid.buttonVerticalPadding)
                            .glassEffect(.regular, in: .capsule)
                            .buttonStyle(.plain)
                    }

                    buttonRow(title: "Regular + Interactive") {
                        Button("Interactive") {}
                            .dsFont(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                            .padding(.vertical, theme.grid.buttonVerticalPadding)
                            .glassEffect(.regular.interactive(), in: .capsule)
                            .buttonStyle(.plain)
                    }

                    buttonRow(title: "Regular + Tint") {
                        Button("Tinted") {}
                            .dsFont(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                            .padding(.vertical, theme.grid.buttonVerticalPadding)
                            .glassEffect(.regular.tint(theme.palette.primary.opacity(theme.glass.tintOpacity)), in: .capsule)
                            .buttonStyle(.plain)
                    }

                    buttonRow(title: "Regular + Tint + Interactive") {
                        Button("Tint + Interactive") {}
                            .dsFont(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                            .padding(.vertical, theme.grid.buttonVerticalPadding)
                            .glassEffect(.regular.tint(theme.palette.warmAccent.opacity(theme.glass.tintOpacity)).interactive(), in: .capsule)
                            .buttonStyle(.plain)
                    }

                    buttonRow(title: "Clear") {
                        Button("Clear") {}
                            .dsFont(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                            .padding(.vertical, theme.grid.buttonVerticalPadding)
                            .glassEffect(.clear, in: .capsule)
                            .buttonStyle(.plain)
                    }

                    buttonRow(title: "Clear + Interactive") {
                        Button("Clear + Interactive") {}
                            .dsFont(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                            .padding(.vertical, theme.grid.buttonVerticalPadding)
                            .glassEffect(.clear.interactive(), in: .capsule)
                            .buttonStyle(.plain)
                    }

                    buttonRow(title: "Clear + Tint") {
                        Button("Clear Tint") {}
                            .dsFont(.headline)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, theme.grid.buttonHorizontalPadding)
                            .padding(.vertical, theme.grid.buttonVerticalPadding)
                            .glassEffect(.clear.tint(theme.palette.glassTint.opacity(theme.glass.tintOpacity)), in: .capsule)
                            .buttonStyle(.plain)
                    }
                }
            } else {
                Text("Requires iOS 26")
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var glassCardsSection: some View {
        section(title: "Glass Cards (Translucency)") {
            if #available(iOS 26.0, *) {
                VStack(spacing: theme.grid.listSpacing) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Regular")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        cardSampleContent
                            .padding(theme.grid.cardPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.regular, in: .rect(cornerRadius: theme.shape.cardCornerRadius))
                            .overlay(cardBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Regular + Tint")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        cardSampleContent
                            .padding(theme.grid.cardPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.regular.tint(theme.palette.primary.opacity(theme.glass.tintOpacity)), in: .rect(cornerRadius: theme.shape.cardCornerRadius))
                            .overlay(cardBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clear")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        cardSampleContent
                            .padding(theme.grid.cardPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.clear, in: .rect(cornerRadius: theme.shape.cardCornerRadius))
                            .overlay(cardBorder)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clear + Tint")
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        cardSampleContent
                            .padding(theme.grid.cardPadding)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .glassEffect(.clear.tint(theme.palette.glassTint.opacity(theme.glass.tintOpacity)), in: .rect(cornerRadius: theme.shape.cardCornerRadius))
                            .overlay(cardBorder)
                    }
                }
            } else {
                Text("Requires iOS 26")
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var glassSheetSection: some View {
        section(title: "Glass Sheets (Translucency)") {
            if #available(iOS 26.0, *) {
                VStack(spacing: theme.grid.listSpacing) {
                    buttonRow(title: "Clear Sheet") {
                        Button("Open") {
                            showClearSheet = true
                        }
                        .dsFont(.headline)
                        .buttonStyle(.nativeGlass)
                        .sheet(isPresented: $showClearSheet) {
                            NavigationStack {
                                VStack(spacing: theme.grid.sectionSpacing) {
                                    Text("Clear Glass Sheet")
                                        .dsFont(.title2, weight: .bold)
                                    Text("Clear glass with minimal tint.")
                                        .dsFont(.body)
                                        .foregroundStyle(.secondary)
                                    Button("Close") {
                                        showClearSheet = false
                                    }
                                    .dsFont(.headline)
                                    .buttonStyle(.nativeGlassProminent)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .background(.clear)
                                .glassEffect(.clear, in: .rect(cornerRadius: theme.shape.cardCornerRadius))
                                .navigationTitle("")
                                #if os(iOS)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbarBackground(.hidden, for: .navigationBar)
                                #endif
                            }
                            .presentationDetents([.medium, .large])
                            .scrollContentBackground(.hidden)
                            .presentationBackground(.clear)
                        }
                    }

                    buttonRow(title: "Regular Sheet") {
                        Button("Open") {
                            showRegularSheet = true
                        }
                        .dsFont(.headline)
                        .buttonStyle(.nativeGlass)
                        .sheet(isPresented: $showRegularSheet) {
                            NavigationStack {
                                VStack(spacing: theme.grid.sectionSpacing) {
                                    Text("Regular Glass Sheet")
                                        .dsFont(.title2, weight: .bold)
                                    Text("Default regular glass effect.")
                                        .dsFont(.body)
                                        .foregroundStyle(.secondary)
                                    Button("Close") {
                                        showRegularSheet = false
                                    }
                                    .dsFont(.headline)
                                    .buttonStyle(.nativeGlassProminent)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .background(.clear)
                                .glassEffect(.regular, in: .rect(cornerRadius: theme.shape.cardCornerRadius))
                                .navigationTitle("")
                                #if os(iOS)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbarBackground(.hidden, for: .navigationBar)
                                #endif
                            }
                            .presentationDetents([.medium, .large])
                            .scrollContentBackground(.hidden)
                            .presentationBackground(.clear)
                        }
                    }

                    buttonRow(title: "Tinted Sheet") {
                        Button("Open") {
                            showTintedSheet = true
                        }
                        .dsFont(.headline)
                        .buttonStyle(.nativeGlass)
                        .sheet(isPresented: $showTintedSheet) {
                            NavigationStack {
                                VStack(spacing: theme.grid.sectionSpacing) {
                                    Text("Tinted Glass Sheet")
                                        .dsFont(.title2, weight: .bold)
                                    Text("Regular glass with warm tint.")
                                        .dsFont(.body)
                                        .foregroundStyle(.secondary)
                                    Button("Close") {
                                        showTintedSheet = false
                                    }
                                    .dsFont(.headline)
                                    .buttonStyle(.nativeGlassProminent)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                                .background(.clear)
                                .glassEffect(.regular.tint(theme.palette.warmAccent.opacity(theme.glass.tintOpacity)), in: .rect(cornerRadius: theme.shape.cardCornerRadius))
                                .navigationTitle("")
                                #if os(iOS)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbarBackground(.hidden, for: .navigationBar)
                                #endif
                            }
                            .presentationDetents([.medium, .large])
                            .scrollContentBackground(.hidden)
                            .presentationBackground(.clear)
                        }
                    }
                }
            } else {
                Text("Requires iOS 26")
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Text(title)
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            panelContainer {
                content()
            }
        }
    }

    private func buttonRow<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(title)
                .dsFont(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            content()
        }
    }

    private func panelContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(theme.grid.cardPadding)
            .frame(maxWidth: .infinity)
            .background(theme.glass.strength.fallbackMaterial, in: RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius, style: .continuous))
            .overlay {
                if theme.shape.borderWidth > 0 {
                    RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(theme.shape.borderOpacity), lineWidth: theme.shape.borderWidth)
                }
            }
    }

    private var cardSampleContent: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Babcia Glass Sample")
                .dsFont(.headline)
            Text("Check translucency against the mesh.")
                .dsFont(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var cardBorder: some View {
        Group {
            if theme.shape.borderWidth > 0 {
                RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(theme.shape.borderOpacity), lineWidth: theme.shape.borderWidth)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ButtonsShowcaseView()
    }
    .environment(AppDependencies())
}
