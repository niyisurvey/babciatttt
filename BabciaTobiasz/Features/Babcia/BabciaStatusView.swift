// BabciaStatusView.swift
// BabciaTobiasz

import SwiftUI

struct BabciaStatusView: View {
    @Bindable var viewModel: AreaViewModel
    @Environment(\.dsTheme) private var theme

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            VStack(spacing: theme.grid.sectionSpacing) {
                Image(status.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 260)
                    .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)

                GlassCardView {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "babciaStatus.pot.title"))
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(viewModel.availablePotPoints)")
                                .dsFont(.title2, weight: .bold)
                            Text(String(localized: "babciaStatus.pot.available"))
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text(String(localized: "babciaStatus.pot.allTime"))
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(viewModel.totalPotPoints)")
                                .dsFont(.headline, weight: .bold)
                        }
                    }
                    .padding(.vertical, 8)
                }

                VStack(spacing: 8) {
                    Text(status.title)
                        .dsFont(.title2, weight: .bold)
                    Text(status.subtitle)
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, theme.grid.cardPadding)
            }
            .padding(.horizontal, theme.grid.cardPadding)
        }
        .onAppear { viewModel.loadAreas() }
    }

    private var status: BabciaStatus {
        if viewModel.hasVerifiedToday {
            return .happy
        }
        if viewModel.hasCompletedUnverifiedToday {
            return .expecting
        }
        return .sad
    }
}

private enum BabciaStatus {
    case happy
    case expecting
    case sad

    var imageName: String {
        switch self {
        case .happy:
            return "R4_Wellness_Portrait_Happy"
        case .expecting:
            return "R4_Wellness_Portrait_Thinking"
        case .sad:
            return "R4_Wellness_Portrait_SadDisappointed"
        }
    }

    var title: String {
        switch self {
        case .happy:
            return String(localized: "babciaStatus.state.happy.title")
        case .expecting:
            return String(localized: "babciaStatus.state.expecting.title")
        case .sad:
            return String(localized: "babciaStatus.state.sad.title")
        }
    }

    var subtitle: String {
        switch self {
        case .happy:
            return String(localized: "babciaStatus.state.happy.subtitle")
        case .expecting:
            return String(localized: "babciaStatus.state.expecting.subtitle")
        case .sad:
            return String(localized: "babciaStatus.state.sad.subtitle")
        }
    }
}

#Preview {
    BabciaStatusView(viewModel: AreaViewModel())
        .environment(AppDependencies())
}
