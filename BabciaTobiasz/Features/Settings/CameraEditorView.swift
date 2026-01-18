//
//  CameraEditorView.swift
//  BabciaTobiasz
//

import SwiftUI

struct CameraEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsTheme) private var theme

    let manager: StreamingCameraManager
    let camera: StreamingCameraConfig?

    @State private var viewModel = CameraEditorViewModel()
    @State private var showError = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground(style: .default)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: theme.grid.sectionSpacing) {
                        basicsCard
                        providerCard

                    }
                    .padding(theme.grid.cardPadding)
                }
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(camera == nil
                         ? String(localized: "cameraSetup.add.title")
                         : String(localized: "cameraSetup.edit.title"))
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
                        saveCamera()
                    }
                }
            }
            .alert(String(localized: "common.error.title"), isPresented: $showError) {
                Button(String(localized: "common.ok")) { showError = false }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                viewModel.populate(from: camera)
            }
        }
    }

    private var basicsCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "cameraSetup.section.basics"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                TextField(
                    String(localized: "cameraSetup.field.name"),
                    text: $viewModel.name
                )
                .dsFont(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var providerCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "cameraSetup.section.provider"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                Picker(String(localized: "cameraSetup.field.type"), selection: $viewModel.providerType) {
                    ForEach(CameraProviderType.allCases) { type in
                        Text(type.localizedName).tag(type)
                            .dsFont(.body)
                    }
                }
                .pickerStyle(.segmented)

                switch viewModel.providerType {
                case .rtsp:
                    TextField(
                        String(localized: "cameraSetup.field.rtspUrl"),
                        text: $viewModel.rtspURL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                    TextField(
                        String(localized: "cameraSetup.field.username"),
                        text: $viewModel.username
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                    SecureField(
                        String(localized: "cameraSetup.field.password"),
                        text: $viewModel.secret
                    )
                    .dsFont(.body)
                case .tapo:
                    TextField(
                        String(localized: "cameraSetup.field.host"),
                        text: $viewModel.host
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                    TextField(
                        String(localized: "cameraSetup.field.port"),
                        text: $viewModel.port
                    )
                    .keyboardType(.numberPad)
                    .dsFont(.body)

                    TextField(
                        String(localized: "cameraSetup.field.username"),
                        text: $viewModel.username
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                    SecureField(
                        String(localized: "cameraSetup.field.password"),
                        text: $viewModel.secret
                    )
                    .dsFont(.body)
                case .homeAssistant:
                    TextField(
                        String(localized: "cameraSetup.field.haBaseUrl"),
                        text: $viewModel.haBaseURL
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                    TextField(
                        String(localized: "cameraSetup.field.haEntityId"),
                        text: $viewModel.haEntityId
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .dsFont(.body)

                    SecureField(
                        String(localized: "cameraSetup.field.haToken"),
                        text: $viewModel.secret
                    )
                    .dsFont(.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func saveCamera() {
        do {
            try viewModel.save(manager: manager, camera: camera)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
