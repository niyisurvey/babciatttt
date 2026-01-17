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
                Text("Dream Engine")
                    .dsFont(.caption, weight: .bold)
                    .foregroundStyle(.secondary)

                Text("API Key")
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                SecureField("Enter DREAMROOM_API_KEY", text: $apiKey)
                    .dsFont(.body)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                HStack(spacing: 12) {
                    Button("Save") {
                        _ = saveKey()
                    }
                    .buttonStyle(.nativeGlassProminent)

                    Button("Clear") {
                        clearKey()
                    }
                    .buttonStyle(.nativeGlass)

                    Button("Test") {
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

                Text("Stored securely on this device. Overrides Secrets.plist if set.")
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
            statusMessage = "Enter a key before saving."
            return false
        }
        apiKey = trimmed
        let saved = DreamRoomKeychain.save(trimmed)
        statusMessage = saved ? "Saved to Keychain." : "Save failed."
        return saved
    }

    private func clearKey() {
        let removed = DreamRoomKeychain.delete()
        apiKey = ""
        statusMessage = removed ? "Removed from Keychain." : "Remove failed."
        testMessage = nil
    }

    private func runTest() async {
        guard saveKey() else {
            testMessage = "Enter a key before testing."
            return
        }
        guard let imageData = SettingsTestImageProvider.loadJPEGData() else {
            testMessage = "Test image unavailable."
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
            testMessage = "Test succeeded."
        } catch {
            testMessage = "Test failed: \(error.localizedDescription)"
        }
        isTesting = false
    }
}
