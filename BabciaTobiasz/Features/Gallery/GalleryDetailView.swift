//
//  GalleryDetailView.swift
//  BabciaTobiasz
//
//  Created 2026-01-15
//

import SwiftUI

struct GalleryDetailView: View {
    let bowl: AreaBowl
    @Environment(\.dsTheme) private var theme

    private var tasks: [CleaningTask] {
        (bowl.tasks ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    private var areaName: String {
        bowl.area?.name ?? "Area"
    }

    private var personaName: String {
        let raw = bowl.area?.personaRaw ?? BabciaPersona.classic.rawValue
        return BabciaPersona(rawValue: raw)?.displayName ?? raw.capitalized
    }

    private var verificationLabel: String {
        switch bowl.verificationTier {
        case .golden: return "Golden Verification"
        case .blue: return "Blue Verification"
        case .none: return "No Verification"
        }
    }

    private var outcomeLabel: String {
        switch bowl.verificationOutcome {
        case .pending: return "Pending"
        case .passed: return "Passed"
        case .failed: return "Failed"
        case .skipped: return "Skipped"
        }
    }

    private var bonusPoints: Int {
        max(0, Int(bowl.totalPoints) - bowl.basePoints)
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerSection
                    imageCard
                    metaCard
                    tasksCard
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
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(areaName)
                .dsFont(.title2, weight: .bold)
            Text(personaName)
                .dsFont(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 4)
    }

    private var imageCard: some View {
        GlassCardView {
            GalleryImageView(imageData: bowl.galleryImageData)
                .frame(height: theme.grid.heroCardHeight)
                .padding(theme.grid.cardPadding)
        }
    }

    private var metaCard: some View {
        GlassCardView {
            VStack(spacing: 12) {
                metadataRow(label: "Created", value: bowl.createdAt.formatted(date: .abbreviated, time: .shortened))
                metadataRow(label: "Verification", value: verificationLabel)
                metadataRow(label: "Outcome", value: outcomeLabel)
                metadataRow(label: "Base Points", value: "\(bowl.basePoints)")
                metadataRow(label: "Bonus Points", value: "\(bonusPoints)")
                metadataRow(label: "Total Points", value: "\(Int(bowl.totalPoints))")
            }
            .padding(.vertical, 6)
        }
    }

    private var tasksCard: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Text("Tasks")
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            GlassCardView {
                if tasks.isEmpty {
                    Text("No tasks recorded for this bowl.")
                        .dsFont(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, theme.grid.sectionSpacing)
                } else {
                    VStack(spacing: 0) {
                        ForEach(tasks, id: \.id) { task in
                            GalleryTaskRow(task: task)
                            if task.id != tasks.last?.id {
                                Divider().padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .dsFont(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .dsFont(.subheadline, weight: .bold)
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Bowl Details")
                .dsFont(.headline, weight: .bold)
                .lineLimit(1)
        }
    }
}

private struct GalleryTaskRow: View {
    let task: CleaningTask
    @Environment(\.dsTheme) private var theme

    var body: some View {
        HStack {
            Text(task.title)
                .dsFont(.body)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .dsFont(.headline)
                .foregroundStyle(
                    task.isCompleted
                        ? AnyShapeStyle(theme.palette.warmAccent)
                        : AnyShapeStyle(.tertiary)
                )
                .frame(width: 36, alignment: .trailing)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        GalleryDetailView(bowl: AreaBowl())
    }
    .dsTheme(.default)
}
