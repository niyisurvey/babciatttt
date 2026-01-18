//
//  SpotCheckCards.swift
//  BabciaTobiasz
//

import SwiftUI

struct SpotCheckHeaderSection: View {
    @Environment(\.dsTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Text(String(localized: "spotCheck.title"))
                .dsFont(.title2, weight: .bold)
            Text(String(localized: "spotCheck.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SpotCheckLimitCard: View {
    let remaining: Int
    let limit: Int
    let points: AppConfig.SpotCheck.Points
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "spotCheck.limit.title"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                Text(String(format: String(localized: "spotCheck.limit.status"), remaining, limit))
                    .dsFont(.headline, weight: .bold)

                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "spotCheck.points.title"))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: String(localized: "spotCheck.points.spotless"), points.spotless))
                        .dsFont(.caption)
                    Text(String(format: String(localized: "spotCheck.points.tidy"), points.tidy))
                        .dsFont(.caption)
                    Text(String(format: String(localized: "spotCheck.points.messy"), points.messy))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SpotCheckMinimumAreasCard: View {
    let minAreas: Int
    let onCreateArea: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "spotCheck.minimum.title"))
                    .dsFont(.headline, weight: .bold)
                Text(String(format: String(localized: "spotCheck.minimum.message"), minAreas))
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                Button {
                    onCreateArea()
                    hapticFeedback(.selection)
                } label: {
                    Label(String(localized: "spotCheck.minimum.action"), systemImage: "plus.circle.fill")
                        .dsFont(.headline)
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SpotCheckRevealCard: View {
    let onReveal: () -> Void
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "spotCheck.reveal.title"))
                    .dsFont(.headline, weight: .bold)
                Text(String(localized: "spotCheck.reveal.prompt"))
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                Button {
                    onReveal()
                } label: {
                    Label(String(localized: "spotCheck.reveal.action"), systemImage: "sparkles")
                        .dsFont(.headline)
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SpotCheckAreaCard: View {
    let area: Area?
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "spotCheck.area.title"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                if let area {
                    Text(area.name)
                        .dsFont(.headline, weight: .bold)
                    Text(area.persona.localizedDisplayName)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(String(localized: "spotCheck.area.empty"))
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SpotCheckAwaitingCard: View {
    var body: some View {
        GlassCardView {
            Text(String(localized: "spotCheck.action.awaiting"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SpotCheckLimitReachedCard: View {
    var body: some View {
        GlassCardView {
            Text(String(localized: "spotCheck.limit.reached"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SpotCheckCooldownCard: View {
    var body: some View {
        GlassCardView {
            Text(String(localized: "spotCheck.cooldown.all"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SpotCheckResultCard: View {
    let result: SpotCheckViewModel.Result
    let areaName: String?
    let taskCount: Int?
    let points: AppConfig.SpotCheck.Points
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "spotCheck.result.title"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                Text(resultTitle)
                    .dsFont(.headline, weight: .bold)

                if let areaName {
                    Text(String(format: String(localized: "spotCheck.result.area"), areaName))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }

                if let taskCount {
                    Text(String(format: String(localized: "spotCheck.result.tasks"), taskCount))
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(String(format: String(localized: "spotCheck.result.points"), resultPoints))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var resultTitle: String {
        switch result {
        case .spotless:
            return String(localized: "spotCheck.result.spotless")
        case .tidy:
            return String(localized: "spotCheck.result.tidy")
        case .messy:
            return String(localized: "spotCheck.result.messy")
        }
    }

    private var resultPoints: Int {
        switch result {
        case .spotless:
            return points.spotless
        case .tidy:
            return points.tidy
        case .messy:
            return points.messy
        }
    }
}

struct SpotCheckResponseCard: View {
    let response: String
    @Environment(\.dsTheme) private var theme

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "spotCheck.response.title"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                Text(response)
                    .dsFont(.headline, weight: .bold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
