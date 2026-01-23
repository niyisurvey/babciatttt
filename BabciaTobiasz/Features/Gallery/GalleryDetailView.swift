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
        bowl.area?.name ?? String(localized: "gallery.detail.area.fallback")
    }

    private var persona: BabciaPersona {
        let raw = bowl.area?.personaRaw ?? BabciaPersona.classic.rawValue
        return BabciaPersona(rawValue: raw) ?? .classic
    }

    private var personaName: String {
        persona.localizedDisplayName
    }

    private var verificationLabel: String {
        switch bowl.verificationTier {
        case .golden: return String(localized: "gallery.detail.verification.golden")
        case .blue: return String(localized: "gallery.detail.verification.blue")
        case .none: return String(localized: "gallery.detail.verification.none")
        }
    }

    private var outcomeLabel: String {
        switch bowl.verificationOutcome {
        case .pending: return String(localized: "gallery.detail.outcome.pending")
        case .passed: return String(localized: "gallery.detail.outcome.passed")
        case .failed: return String(localized: "gallery.detail.outcome.failed")
        case .skipped: return String(localized: "gallery.detail.outcome.skipped")
        }
    }

    private var bonusPoints: Int {
        max(0, Int(bowl.totalPoints) - bowl.basePoints)
    }

    @State private var headerProgress: CGFloat = 0

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScalingHeaderScrollView(
                maxHeight: theme.grid.heroCardHeight,
                minHeight: theme.grid.heroHeaderCollapsedHeight,
                snapMode: .none,
                progress: $headerProgress
            ) { progress in
                dreamHeroImage(progress: progress)
            } content: {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerSection
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

    @ViewBuilder
    private func dreamHeroImage(progress: CGFloat) -> some View {
        Group {
            if let imageData = bowl.galleryImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                DreamHeaderPlaceholderView(
                    title: String(localized: "gallery.detail.hero.placeholder.title"),
                    message: String(localized: "gallery.detail.hero.placeholder.message"),
                    icon: "photo"
                )
            }
        }
        .opacity(max(0.0, 1.0 - progress * 1.2))
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(areaName)
                .dsFont(.title2, weight: .bold)
            personaBadge
        }
        .padding(.top, 4)
    }

    private var metaCard: some View {
        GlassCardView {
            VStack(spacing: 12) {
                metadataRow(label: String(localized: "gallery.detail.meta.created"), value: bowl.createdAt.formatted(date: .abbreviated, time: .shortened))
                metadataRow(label: String(localized: "gallery.detail.meta.babcia"), value: personaName)
                metadataRow(label: String(localized: "gallery.detail.meta.verification"), value: verificationLabel)
                metadataRow(label: String(localized: "gallery.detail.meta.outcome"), value: outcomeLabel)
                metadataRow(label: String(localized: "gallery.detail.meta.basePoints"), value: "\(bowl.basePoints)")
                metadataRow(label: String(localized: "gallery.detail.meta.bonusPoints"), value: "\(bonusPoints)")
                metadataRow(label: String(localized: "gallery.detail.meta.totalPoints"), value: "\(Int(bowl.totalPoints))")
            }
            .padding(.vertical, 6)
        }
    }

    private var tasksCard: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Text(String(localized: "gallery.detail.tasks.title"))
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            GlassCardView {
                if tasks.isEmpty {
                    Text(String(localized: "gallery.detail.tasks.empty"))
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

    private var personaBadge: some View {
        HStack(spacing: 8) {
            personaHeadshot
            Text(persona.localizedDisplayName)
                .dsFont(.caption, weight: .bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(
            Capsule()
                .stroke(theme.palette.glassTint.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var personaHeadshot: some View {
        if let uiImage = UIImage(named: persona.headshotImageName) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: theme.grid.iconSmall, height: theme.grid.iconSmall)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(theme.glass.strength.fallbackMaterial)
                .frame(width: theme.grid.iconSmall, height: theme.grid.iconSmall)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: theme.grid.iconTiny))
                        .foregroundStyle(theme.palette.secondary)
                )
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(String(localized: "gallery.detail.toolbar.title"))
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
