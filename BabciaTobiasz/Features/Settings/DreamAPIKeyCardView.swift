//
//  DreamAPIKeyCardView.swift
//  BabciaTobiasz
//
//  Settings UI for the DreamRoom API key.
//

import SwiftUI

struct DreamAPIKeyCardView: View {
    @State private var apiKey: String = DreamRoomSecrets.apiKey() ?? ""
    @State private var statusMessage: String?
    @State private var testMessage: String?
    @State private var isTesting = false

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "settings.apiKeys.dream.title"))
                    .dsFont(.caption, weight: .bold)
                    .foregroundStyle(.secondary)

                Text(String(localized: "settings.apiKeys.dream.helper"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                Text(String(localized: "settings.apiKeys.dream.where"))
                    .dsFont(.caption2)
                    .foregroundStyle(.secondary)

                Text(String(localized: "settings.apiKeys.apiKey.label"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                SecureField(String(localized: "settings.apiKeys.dream.placeholder"), text: $apiKey)
                    .dsFont(.body)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                HStack(spacing: 12) {
                    Button(String(localized: "common.save")) {
                        _ = saveKey()
                    }
                    .buttonStyle(.nativeGlassProminent)

                    Button(String(localized: "common.clear")) {
                        clearKey()
                    }
                    .buttonStyle(.nativeGlass)

                    Button(String(localized: "common.test")) {
                        Task { await runTest() }
                    }
                    .buttonStyle(.nativeGlass)
                    .disabled(isTesting)

                    if isTesting {
                        ProgressView()
                            .scaleEffect(0.8)
                    }

                    Spacer()
                }

                Text(String(localized: "settings.apiKeys.stored"))
                    .dsFont(.caption2)
                    .foregroundStyle(.secondary)

                if let statusMessage {
                    Text(statusMessage)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }

                if let testMessage {
                    Text(testMessage)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Private Helpers

    private func saveKey() -> Bool {
        let trimmed = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusMessage = String(localized: "settings.apiKeys.status.enterBeforeSaving")
            return false
        }
        apiKey = trimmed
        let saved = DreamRoomKeychain.save(trimmed)
        statusMessage = saved
            ? String(localized: "settings.apiKeys.status.saved")
            : String(localized: "settings.apiKeys.status.saveFailed")
        return saved
    }

    private func clearKey() {
        let removed = DreamRoomKeychain.delete()
        apiKey = ""
        statusMessage = removed
            ? String(localized: "settings.apiKeys.status.removed")
            : String(localized: "settings.apiKeys.status.removeFailed")
        testMessage = nil
    }

    private func runTest() async {
        guard saveKey() else {
            testMessage = String(localized: "settings.apiKeys.status.enterBeforeTesting")
            return
        }
        guard let imageData = SettingsTestImageProvider.loadJPEGData() else {
            testMessage = String(localized: "settings.apiKeys.status.testImageUnavailable")
            return
        }
        isTesting = true
        testMessage = nil
        do {
            let service = DreamPipelineService()
            _ = try await service.generateDream(
                beforePhotoData: imageData,
                characterPrompt: "A tidy, cozy room.",
                filterId: nil
            )
            testMessage = String(localized: "settings.apiKeys.status.testSucceeded")
        } catch {
            testMessage = String(
                format: String(localized: "settings.apiKeys.status.testFailed"),
                error.localizedDescription
            )
        }
        isTesting = false
    }
}
