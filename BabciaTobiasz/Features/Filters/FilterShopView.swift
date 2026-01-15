// FilterShopView.swift
// BabciaTobiasz

import SwiftUI

struct FilterShopView: View {
    @Bindable var viewModel: AreaViewModel
    @Environment(\.dsTheme) private var theme

    private let filters: [FilterItem] = [
        FilterItem(
            id: "dream-honey",
            name: "Dream Honey",
            description: "Warm glow with soft highlights.",
            cost: 4000,
            ingredientNote: "Onions x4 + Tomatoes x7"
        ),
        FilterItem(
            id: "glass-moss",
            name: "Glass Moss",
            description: "Cool mist and gentle contrast.",
            cost: 5200,
            ingredientNote: "Leeks x3 + Mint x5"
        ),
        FilterItem(
            id: "pierogi-gold",
            name: "Pierogi Gold",
            description: "Bright, celebratory sheen.",
            cost: 7000,
            ingredientNote: "Butter x6 + Garlic x4"
        )
    ]

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerSection
                    pointsSection
                    filtersSection
                }
                .padding(.horizontal, theme.grid.cardPadding)
                .padding(.vertical, theme.grid.sectionSpacing)
            }
        }
        .navigationTitle("")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar { toolbarContent }
        .onAppear { viewModel.loadAreas() }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Dream Vision Filters")
                .dsFont(.title2, weight: .bold)
            Text("Spend points to unlock filters for your Dream images.")
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var pointsSection: some View {
        GlassCardView {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available")
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.availablePotPoints)")
                        .dsFont(.title2, weight: .bold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("All Time")
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.totalPotPoints)")
                        .dsFont(.headline, weight: .bold)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var filtersSection: some View {
        VStack(spacing: theme.grid.listSpacing) {
            ForEach(filters) { filter in
                filterCard(filter)
            }
        }
    }

    private func filterCard(_ filter: FilterItem) -> some View {
        let unlocked = viewModel.isFilterUnlocked(filter.id)
        let isActive = viewModel.activeFilterId == filter.id
        let canAfford = viewModel.availablePotPoints >= filter.cost

        return GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(filter.name)
                            .dsFont(.headline, weight: .bold)
                        Text(filter.description)
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(filter.cost)")
                        .dsFont(.headline, weight: .bold)
                }

                Text(filter.ingredientNote)
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                HStack {
                    if unlocked {
                        if isActive {
                            Text("Applied")
                                .dsFont(.caption, weight: .bold)
                                .foregroundStyle(.secondary)
                        } else {
                            Button("Apply") {
                                viewModel.applyFilter(filter.id)
                            }
                            .buttonStyle(.nativeGlass)
                        }
                    } else {
                        Button("Unlock") {
                            viewModel.unlockFilter(filter.id, cost: filter.cost)
                        }
                        .buttonStyle(.nativeGlassProminent)
                        .disabled(!canAfford)
                    }

                    Spacer()
                }
            }
            .padding(.vertical, 8)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Filter Shop")
                .dsFont(.headline, weight: .bold)
                .lineLimit(1)
        }
    }
}

private struct FilterItem: Identifiable {
    let id: String
    let name: String
    let description: String
    let cost: Int
    let ingredientNote: String
}

#Preview {
    NavigationStack {
        FilterShopView(viewModel: AreaViewModel())
    }
    .environment(AppDependencies())
}
