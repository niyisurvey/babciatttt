//
//  GalleryView.swift
//  BabciaTobiasz
//
//  Created 2026-01-15
//

import SwiftUI
import SwiftData

struct GalleryView: View {
    @Bindable var areaViewModel: AreaViewModel
    @Environment(\.dsTheme) private var theme
    @Query(sort: [SortDescriptor(\AreaBowl.createdAt, order: .reverse)]) private var bowls: [AreaBowl]
    @State private var selectedBowl: AreaBowl?
    @State private var showDetail = false

    private var galleryBowls: [AreaBowl] {
        bowls.filter { $0.galleryImageData != nil }
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerSection

                    if galleryBowls.isEmpty {
                        emptyStateCard
                    } else {
                        galleryGrid
                    }
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
        .onAppear { areaViewModel.loadAreas() }
        .navigationDestination(isPresented: $showDetail) {
            if let selectedBowl {
                GalleryDetailView(bowl: selectedBowl)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(String(localized: "gallery.title"))
                .dsFont(.title2, weight: .bold)
            Text(String(localized: "gallery.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var galleryGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: theme.grid.listSpacing),
                GridItem(.flexible(), spacing: theme.grid.listSpacing)
            ],
            spacing: theme.grid.listSpacing
        ) {
            ForEach(galleryBowls, id: \.id) { bowl in
                GalleryItemCard(bowl: bowl) {
                    selectedBowl = bowl
                    showDetail = true
                }
            }
        }
    }

    private var emptyStateCard: some View {
        GlassCardView {
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundStyle(theme.palette.primary)
                    .font(.system(size: theme.grid.iconXL))

                Text(String(localized: "gallery.empty.title"))
                    .dsFont(.headline, weight: .bold)

                Text(String(localized: "gallery.empty.message"))
                    .dsFont(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, theme.grid.sectionSpacing)
            .padding(.horizontal, theme.grid.cardPadding)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(String(localized: "gallery.toolbar.title"))
                .dsFont(.headline, weight: .bold)
                .lineLimit(1)
        }
    }
}

#Preview {
    let schema = Schema([Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, ReminderConfig.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])

    return NavigationStack {
        GalleryView(areaViewModel: AreaViewModel())
    }
    .modelContainer(container)
    .dsTheme(.default)
}
