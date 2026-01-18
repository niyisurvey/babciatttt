//
//  TapoQuickAddView.swift
//  BabciaTobiasz
//

import SwiftUI

struct TapoQuickAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsTheme) private var theme

    let manager: StreamingCameraManager
    let discovery: StreamingCameraDiscoveryResult

    @State private var name: String
    @State private var host: String
    @State private var port: String
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showError = false
    @State private var errorMessage: String = ""

    init(manager: StreamingCameraManager, discovery: StreamingCameraDiscoveryResult) {
        self.manager = manager
        self.discovery = discovery
        _name = State(initialValue: discovery.name.isEmpty ? "Tapo Camera" : discovery.name)
        _host = State(initialValue: discovery.host)
        if let port = discovery.port {
            _port = State(initialValue: String(port))
        } else {
            _port = State(initialValue: "")
        }
    }

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    headerCard
                    formCard
                }
                .padding(theme.grid.cardPadding)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String(localized: "cameraSetup.tapo.title"))
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
                Text(String(localized: "cameraSetup.quickAdd.tapo"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)
                Text(String(localized: "cameraSetup.tapo.helper"))
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

                TextField(String(localized: "cameraSetup.field.host"), text: $host)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                TextField(String(localized: "cameraSetup.field.port"), text: $port)
                    .keyboardType(.numberPad)
                    .dsFont(.body)

                TextField(String(localized: "cameraSetup.field.username"), text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                SecureField(String(localized: "cameraSetup.field.password"), text: $password)
                    .dsFont(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func save() {
        do {
            try validate()
            let config = StreamingCameraConfig(
                name: name,
                providerType: .tapo,
                host: host,
                port: Int(port),
                username: username
            )
            manager.addCamera(config, secret: password)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func validate() throws {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError(String(localized: "cameraSetup.validation.name"))
        }
        if host.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError(String(localized: "cameraSetup.validation.host"))
        }
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError(String(localized: "cameraSetup.validation.username"))
        }
        if password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw ValidationError(String(localized: "cameraSetup.validation.secret"))
        }
    }
}

private struct ValidationError: LocalizedError {
    let message: String
    init(_ message: String) { self.message = message }
    var errorDescription: String? { message }
}
