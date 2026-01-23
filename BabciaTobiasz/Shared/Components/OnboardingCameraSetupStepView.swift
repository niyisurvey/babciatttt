//
//  OnboardingCameraSetupStepView.swift
//  BabciaTobiasz
//

import SwiftUI
import SwiftData

struct OnboardingCameraSetupStepView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dsTheme) private var theme

    @State private var streamingManager = StreamingCameraManager()
    @State private var showCameraSetup = false
    @State private var showCameraEditor = false

    var body: some View {
        VStack(spacing: theme.grid.sectionSpacing) {
            header

            GlassCardView {
                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                    Text(String(localized: "onboarding.camera.supportedTitle"))
                        .dsFont(.headline, weight: .bold)

                    StreamingCameraSupportedListView()

                    if streamingManager.configs.isEmpty {
                        Text(String(localized: "onboarding.camera.empty"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(String(format: String(localized: "onboarding.camera.configured"), streamingManager.configs.count))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: theme.grid.listSpacing) {
                        Button(String(localized: "onboarding.camera.scan")) {
                            showCameraSetup = true
                            hapticFeedback(.selection)
                        }
                        .buttonStyle(.nativeGlassProminent)
                        .frame(maxWidth: .infinity)

                        Button(String(localized: "onboarding.camera.manual")) {
                            showCameraEditor = true
                            hapticFeedback(.selection)
                        }
                        .buttonStyle(.nativeGlass)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(theme.grid.cardPadding)
            }

            Text(String(localized: "onboarding.camera.helper"))
                .dsFont(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, theme.grid.cardPadding)
        }
        .padding(.horizontal, theme.grid.cardPadding)
        .onAppear {
            streamingManager.configure(modelContext: modelContext)
            streamingManager.loadConfigs()
        }
        .sheet(isPresented: $showCameraSetup) {
            NavigationStack {
                CameraSetupView()
            }
        }
        .sheet(isPresented: $showCameraEditor) {
            NavigationStack {
                CameraEditorView(manager: streamingManager, camera: nil)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text(String(localized: "onboarding.camera.title"))
                .dsFont(.title, weight: .bold)
                .multilineTextAlignment(.center)

            Text(String(localized: "onboarding.camera.subtitle"))
                .dsFont(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    OnboardingCameraSetupStepView()
        .modelContainer(for: [StreamingCameraConfig.self], inMemory: true)
        .dsTheme(.default)
}
