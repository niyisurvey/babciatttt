//
//  HomeAssistantQuickAddView.swift
//  BabciaTobiasz
//

import SwiftUI

struct HomeAssistantQuickAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsTheme) private var theme

    let manager: StreamingCameraManager
    let discovery: StreamingCameraDiscoveryResult

    @State private var name: String
    @State private var baseURL: String
    @State private var token: String = ""
    @State private var entities: [HomeAssistantCameraEntity] = []
    @State private var selectedEntityId: String?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage: String = ""

    private let entityService = HomeAssistantEntityService()

    init(manager: StreamingCameraManager, discovery: StreamingCameraDiscoveryResult) {
        self.manager = manager
        self.discovery = discovery
        _name = State(initialValue: discovery.name.isEmpty ? "Home Assistant" : discovery.name)
        _baseURL = State(initialValue: HomeAssistantQuickAddView.defaultBaseURL(from: discovery))
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerCard
                    formCard
                    entityCard
                }
                .padding(theme.grid.cardPadding)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String(localized: "cameraSetup.ha.title"))
                    .dsFont(.title2, weight: .bold)
                    .lineLimit(1)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "cameraSetup.cancel")) {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "cameraSetup.save")) {
                    save()
                }
            }
        }
        .alert(String(localized: "common.error.title"), isPresented: $showError) {
            Button(String(localized: "common.ok")) { showError = false }
        } message: {
            Text(errorMessage)
        }
    }

    private var headerCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "cameraSetup.quickAdd.homeAssistant"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                Text(String(localized: "cameraSetup.ha.helper"))
                    .dsFont(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var formCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "cameraSetup.section.basics"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                TextField(String(localized: "cameraSetup.field.name"), text: $name)
                    .dsFont(.body)

                TextField(String(localized: "cameraSetup.field.haBaseUrl"), text: $baseURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                SecureField(String(localized: "cameraSetup.field.haToken"), text: $token)
                    .dsFont(.body)

                Button(action: fetchEntities) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(String(localized: "cameraSetup.ha.fetch"))
                            .dsFont(.headline)
                    }
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var entityCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "cameraSetup.ha.select"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                if entities.isEmpty {
                    Text(String(localized: "cameraSetup.ha.empty"))
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(entities) { entity in
                        Button {
                            selectedEntityId = entity.id
                            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                name = entity.name
                            }
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entity.name)
                                        .dsFont(.body)
                                    Text(entity.id)
                                        .dsFont(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Image(systemName: selectedEntityId == entity.id ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(selectedEntityId == entity.id ? theme.palette.primary : .secondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func fetchEntities() {
        Task {
            do {
                try validateBasics()
                isLoading = true
                let url = try parseBaseURL()
                let fetched = try await entityService.fetchCameraEntities(baseURL: url, token: token)
                entities = fetched
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func save() {
        do {
            try validateBasics()
            guard let selectedEntityId else {
                throw ValidationError(String(localized: "cameraSetup.validation.haEntityId"))
            }
            let url = try parseBaseURL()
            let config = StreamingCameraConfig(
                name: name,
                providerType: .homeAssistant,
                homeAssistantBaseURL: url.absoluteString,
                cameraEntityId: selectedEntityId
            )
            manager.addCamera(config, secret: token)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func validateBasics() throws {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError(String(localized: "cameraSetup.validation.name"))
        }
        if baseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError(String(localized: "cameraSetup.validation.haBaseUrl"))
        }
        if token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError(String(localized: "cameraSetup.validation.secret"))
        }
    }

    private func parseBaseURL() throws -> URL {
        guard let url = URL(string: baseURL) else {
            throw ValidationError(String(localized: "cameraSetup.validation.haBaseUrl"))
        }
        return url
    }

    private static func defaultBaseURL(from discovery: StreamingCameraDiscoveryResult) -> String {
        if let url = discovery.suggestedURL {
            return url.absoluteString
        }
        if let port = discovery.port {
            return "http://\(discovery.host):\(port)"
        }
        return "http://\(discovery.host)"
    }
}

private struct ValidationError: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}
