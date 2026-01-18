// FilterShopView.swift
// BabciaTobiasz

import SwiftUI

struct FilterShopView: View {
    @Bindable var viewModel: AreaViewModel
    @Environment(\.dsTheme) private var theme

    private let filters: [FilterItem] = [
        FilterItem(
            id: "dream-honey",
            name: String(localized: "filters.dreamHoney.name"),
            description: String(localized: "filters.dreamHoney.description"),
            cost: 4000,
            ingredientNote: String(localized: "filters.dreamHoney.ingredients")
        ),
        FilterItem(
            id: "glass-moss",
            name: String(localized: "filters.glassMoss.name"),
            description: String(localized: "filters.glassMoss.description"),
            cost: 5200,
            ingredientNote: String(localized: "filters.glassMoss.ingredients")
        ),
        FilterItem(
            id: "pierogi-gold",
            name: String(localized: "filters.pierogiGold.name"),
            description: String(localized: "filters.pierogiGold.description"),
            cost: 7000,
            ingredientNote: String(localized: "filters.pierogiGold.ingredients")
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
        .alert(String(localized: "common.error.title"), isPresented: $viewModel.showError) {
            Button(String(localized: "common.ok")) { viewModel.dismissError() }
        } message: {
            Text(viewModel.errorMessage ?? String(localized: "common.error.fallback"))
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(String(localized: "filters.title"))
                .dsFont(.title2, weight: .bold)
            Text(String(localized: "filters.subtitle"))
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
                    Text(String(localized: "filters.points.available"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.availablePotPoints)")
                        .dsFont(.title2, weight: .bold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(localized: "filters.points.allTime"))
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
                            Text(String(localized: "filters.action.applied"))
                                .dsFont(.caption, weight: .bold)
                                .foregroundStyle(.secondary)
                        } else {
                            Button(String(localized: "filters.action.apply")) {
                                viewModel.applyFilter(filter.id)
                            }
                            .buttonStyle(.nativeGlass)
                        }
                    } else {
                        Button(String(localized: "filters.action.unlock")) {
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
            Text(String(localized: "filters.toolbar.title"))
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
