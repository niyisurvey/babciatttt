// SettingsView.swift
// BabciaTobiasz

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @AppStorage("temperatureUnit") private var temperatureUnit: TemperatureUnit = .celsius
    @State private var dreamApiKey: String = DreamRoomKeychain.load() ?? ""
    @State private var dreamKeyStatus: String?
    
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
                            Text("Appearance")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            
                            GlassCardView {
                                Picker("Theme", selection: $appTheme) {
                                    ForEach(AppTheme.allCases) { theme in
                                        Text(theme.rawValue.capitalized).tag(theme)
                                            .dsFont(.body)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Units Section
                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text("Units")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            
                            GlassCardView {
                                Picker("Temperature", selection: $temperatureUnit) {
                                    ForEach(TemperatureUnit.allCases) { unit in
                                        Text(unit.rawValue.capitalized).tag(unit)
                                            .dsFont(.body)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.vertical, 4)
                            }
                        }

                        // Dream Engine Section
                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text("Dream Engine")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("API Key")
                                        .dsFont(.caption)
                                        .foregroundStyle(.secondary)

                                    SecureField("Enter DREAMROOM_API_KEY", text: $dreamApiKey)
                                        .dsFont(.body)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()

                                    HStack(spacing: 12) {
                                        Button("Save") {
                                            let trimmed = dreamApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                                            guard !trimmed.isEmpty else {
                                                dreamKeyStatus = "Enter a key before saving."
                                                return
                                            }
                                            dreamApiKey = trimmed
                                            dreamKeyStatus = DreamRoomKeychain.save(trimmed) ? "Saved to Keychain." : "Save failed."
                                        }
                                        .buttonStyle(.nativeGlassProminent)

                                        Button("Clear") {
                                            let removed = DreamRoomKeychain.delete()
                                            dreamApiKey = ""
                                            dreamKeyStatus = removed ? "Removed from Keychain." : "Remove failed."
                                        }
                                        .buttonStyle(.nativeGlass)

                                        Spacer()
                                    }

                                    Text("Stored securely on this device. Overrides Secrets.plist if set.")
                                        .dsFont(.caption2)
                                        .foregroundStyle(.secondary)

                                    if let dreamKeyStatus {
                                        Text(dreamKeyStatus)
                                            .dsFont(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }

                        // Added 2026-01-15 08:10 GMT
                        // Liquid Glass Lab Section (temporary)
                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text("Liquid Glass Lab")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                NavigationLink {
                                    ButtonsShowcaseView()
                                } label: {
                                    HStack {
                                        Text("Open Liquid Glass Lab")
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
                            Text("About")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            
                            GlassCardView {
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Version").dsFont(.body)
                                        Spacer()
                                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                            .dsFont(.body)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("Build").dsFont(.body)
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
                    Text("Settings")
                        .dsFont(.title2, weight: .bold)
                        .lineLimit(1)
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
}

enum TemperatureUnit: String, CaseIterable, Identifiable {
    case celsius, fahrenheit
    var id: Self { self }
}

#Preview {
    SettingsView()
}
