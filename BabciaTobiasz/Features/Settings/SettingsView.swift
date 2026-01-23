// SettingsView.swift
// BabciaTobiasz

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @State private var showChangelog = false
    
    @Environment(\.dsTheme) private var theme
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: theme.grid.sectionSpacing) {
                        // Appearance Section
                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "settings.appearance.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            
                            GlassCardView {
                                Picker(String(localized: "settings.appearance.theme.label"), selection: $appTheme) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.localizedName).tag(theme)
                                            .dsFont(.body)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.vertical, 4)
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "settings.babcia.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            Text(String(localized: "settings.babcia.subtitle"))
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                NavigationLink {
                                    BabciaPersonaSettingsView()
                                } label: {
                                    HStack {
                                        Text(String(localized: "settings.babcia.action"))
                                            .dsFont(.headline)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: theme.grid.iconTiny))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }

                        APIKeysSectionView()

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "settings.cameras.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            Text(String(localized: "settings.cameras.subtitle"))
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                NavigationLink {
                                    CameraSetupView()
                                } label: {
                                    HStack {
                                        Text(String(localized: "settings.cameras.action"))
                                            .dsFont(.headline)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: theme.grid.iconTiny))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "settings.microTidy.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            Text(String(localized: "settings.microTidy.subtitle"))
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                NavigationLink {
                                    MicroTidyView(onOpenAreas: {
                                        AppIntentRoute.store(.areas)
                                    })
                                } label: {
                                    HStack {
                                        Text(String(localized: "settings.microTidy.action"))
                                            .dsFont(.headline)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: theme.grid.iconTiny))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }



                        // Analytics Section
                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "settings.analytics.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                NavigationLink {
                                    AnalyticsView()
                                } label: {
                                    HStack {
                                        Text(String(localized: "settings.analytics.action"))
                                            .dsFont(.headline)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: theme.grid.iconTiny))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }

                        // About Section
                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "settings.about.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            
                            GlassCardView {
                                VStack(spacing: 16) {
                                    Button {
                                        showChangelog = true
                                    } label: {
                                        HStack {
                                            Text(String(localized: "settings.about.version"))
                                                .dsFont(.body)
                                            Spacer()
                                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                                .dsFont(.body)
                                                .foregroundStyle(.secondary)
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: theme.grid.iconTiny))
                                                .foregroundStyle(.tertiary)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text(String(localized: "settings.about.build")).dsFont(.body)
                                        Spacer()
                                        Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                                            .dsFont(.body)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
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
                    Text(String(localized: "settings.toolbar.title"))
                        .dsFont(.title2, weight: .bold)
                        .lineLimit(1)
                }
            }
            .sheet(isPresented: $showChangelog) {
                NavigationStack {
                    ChangelogView()
                }
            }
        }
    }
    
    private var backgroundGradient: some View {
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: [
                    theme.palette.primary.opacity(0.15),
                    theme.palette.secondary.opacity(0.1),
                    theme.palette.tertiary.opacity(0.15),
                    theme.palette.secondary.opacity(0.1),
                    theme.palette.primary.opacity(0.2),
                    theme.palette.tertiary.opacity(0.1),
                    theme.palette.primary.opacity(0.1),
                    theme.palette.secondary.opacity(0.15),
                    theme.palette.tertiary.opacity(0.15)
                ]
            )
        }
        .ignoresSafeArea()
    }
    
    private func animatedMeshPoints(for date: Date) -> [SIMD2<Float>] {
        let time = Float(date.timeIntervalSince1970)
        let interval = Float(max(theme.motion.meshAnimationInterval, 0.1))
        let baseSpeed = 1.0 / interval
        let offset = sin(time * (baseSpeed * 0.5)) * 0.2
        let offset2 = cos(time * (baseSpeed * 0.35)) * 0.14
        return [
            [0.0, 0.0], [0.5 + offset2, 0.0], [1.0, 0.0],
            [0.0, 0.5], [0.5 + offset, 0.5 - offset], [1.0, 0.5],
            [0.0, 1.0], [0.5 - offset2, 1.0], [1.0, 1.0]
        ]
    }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: Self { self }

    var localizedName: String {
        switch self {
        case .system:
            return String(localized: "settings.theme.system")
        case .light:
            return String(localized: "settings.theme.light")
        case .dark:
            return String(localized: "settings.theme.dark")
        }
    }
}



#Preview {
    SettingsView()
}
