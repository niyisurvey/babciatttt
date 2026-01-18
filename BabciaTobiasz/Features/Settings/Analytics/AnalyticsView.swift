//
//  AnalyticsView.swift
//  BabciaTobiasz
//
//  Created 2026-01-15
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.dsTheme) private var theme
    @Query(sort: [SortDescriptor(\TaskCompletionEvent.completedAt, order: .reverse)]) private var events: [TaskCompletionEvent]

    private var uniqueAreasCount: Int {
        Set(events.compactMap { $0.areaId }).count
    }

    private var mostRecentDate: Date? {
        events.first?.completedAt
    }

    private var dayOfWeekCounts: [(String, Int)] {
        let symbols = Calendar.current.shortWeekdaySymbols
        var counts = Array(repeating: 0, count: 7)
        for event in events {
            let index = max(1, min(7, event.dayOfWeek)) - 1
            counts[index] += 1
        }
        return zip(symbols, counts).map { ($0.0, $0.1) }
    }

    private var hourOfDayCounts: [(String, Int)] {
        var counts = Array(repeating: 0, count: 24)
        for event in events {
            let index = max(0, min(23, event.hourOfDay))
            counts[index] += 1
        }
        return counts.enumerated().map { index, count in
            (String(format: "%02d:00", index), count)
        }
    }

    private var topAreas: [(String, Int)] {
        let grouped = Dictionary(grouping: events, by: { $0.areaName.isEmpty ? String(localized: "analytics.topAreas.unknown") : $0.areaName })
        return grouped
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { $0 }
    }

    private var topPersonas: [(String, Int)] {
        let grouped = Dictionary(grouping: events, by: { $0.personaRaw })
        return grouped
            .map { (personaDisplayName($0.key), $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(5)
            .map { $0 }
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerSection
                    summaryCards
                    patternsSection
                    eventList
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
            Text(String(localized: "analytics.title"))
                .dsFont(.title2, weight: .bold)
            Text(String(localized: "analytics.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var summaryCards: some View {
        VStack(spacing: theme.grid.listSpacing) {
            GlassCardView {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "analytics.summary.totalCompletions"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(events.count)")
                            .dsFont(.title2, weight: .bold)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(String(localized: "analytics.summary.uniqueAreas"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(uniqueAreasCount)")
                            .dsFont(.title3, weight: .bold)
                    }
                }
                .padding(.vertical, 8)
            }

            GlassCardView {
                HStack {
                    Text(String(localized: "analytics.summary.mostRecent"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(mostRecentDate?.formatted(date: .abbreviated, time: .shortened) ?? "—")
                        .dsFont(.subheadline, weight: .bold)
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Text(String(localized: "analytics.patterns.title"))
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            GlassCardView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "analytics.patterns.dayOfWeek"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    AnalyticsCountList(items: dayOfWeekCounts)
                }
                .padding(.vertical, 6)
            }

            GlassCardView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "analytics.patterns.hour"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    AnalyticsCountList(items: hourOfDayCounts)
                }
                .padding(.vertical, 6)
            }

            GlassCardView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "analytics.patterns.topAreas"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    AnalyticsCountList(items: topAreas)
                }
                .padding(.vertical, 6)
            }

            GlassCardView {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "analytics.patterns.topPersonas"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    AnalyticsCountList(items: topPersonas)
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var eventList: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Text(String(localized: "analytics.events.title"))
                .dsFont(.headline, weight: .bold)
                .padding(.horizontal, 4)

            if events.isEmpty {
                GlassCardView {
                    VStack(spacing: 12) {
                        Image(systemName: "chart.bar")
                            .foregroundStyle(theme.palette.primary)
                            .font(.system(size: theme.grid.iconLarge))
                        Text(String(localized: "analytics.events.empty.title"))
                            .dsFont(.headline, weight: .bold)
                        Text(String(localized: "analytics.events.empty.message"))
                            .dsFont(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, theme.grid.sectionSpacing)
                }
            } else {
                GlassCardView {
                    VStack(spacing: 0) {
                        ForEach(events) { event in
                            AnalyticsEventRow(event: event)
                            if event.id != events.last?.id {
                                Divider().padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(String(localized: "analytics.toolbar.title"))
                .dsFont(.headline, weight: .bold)
                .lineLimit(1)
        }
    }
}

private struct AnalyticsCountList: View {
    let items: [(String, Int)]

    var body: some View {
        VStack(spacing: 8) {
            if items.isEmpty {
                Text(String(localized: "analytics.countList.empty"))
                    .dsFont(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items, id: \.0) { item in
                    HStack {
                        Text(item.0)
                            .dsFont(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(item.1)")
                            .dsFont(.subheadline, weight: .bold)
                    }
                }
            }
        }
    }
}

private struct AnalyticsEventRow: View {
    let event: TaskCompletionEvent
    @Environment(\.dsTheme) private var theme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(theme.palette.warmAccent)
                .font(.system(size: theme.grid.iconSmall))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.taskTitle)
                    .dsFont(.headline)
                    .lineLimit(1)

                Text(event.areaName.isEmpty ? String(localized: "analytics.event.area.fallback") : event.areaName)
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(event.completedAt.formatted(date: .abbreviated, time: .shortened))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: String(localized: "analytics.event.points"), event.taskPoints))
                    .dsFont(.caption, weight: .bold)
            }
        }
        .padding(.vertical, 6)
    }
}

private func personaDisplayName(_ raw: String) -> String {
    BabciaPersona(rawValue: raw)?.localizedDisplayName ?? raw.capitalized
}

#Preview {
    let schema = Schema([TaskCompletionEvent.self])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let context = container.mainContext

    let sample = TaskCompletionEvent(
        completedAt: Date(),
        dayOfWeek: 3,
        hourOfDay: 14,
        taskTitle: "Wipe counters",
        taskPoints: 2,
        areaId: nil,
        areaName: "Kitchen",
        personaRaw: "classic",
        bowlId: nil
    )
    context.insert(sample)

    return NavigationStack {
        AnalyticsView()
    }
    .modelContainer(container)
    .dsTheme(.default)
}
