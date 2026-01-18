//
//  CameraSetupView.swift
//  BabciaTobiasz
//

import SwiftUI
import SwiftData

struct CameraSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dsTheme) private var theme

    @State private var manager = StreamingCameraManager()
    @State private var discoveryHub = StreamingCameraDiscoveryHub()
    @State private var selectedDiscovery: StreamingCameraDiscoveryResult?
    @State private var showEditor = false
    @State private var editingCamera: StreamingCameraConfig?
    @State private var showDeleteConfirmation = false
    @State private var pendingDelete: StreamingCameraConfig?

    var body: some View {
        ZStack {
            LiquidGlassBackground(style: .default)

            ScrollView(showsIndicators: false) {
                VStack(spacing: theme.grid.sectionSpacing) {
                    quickAddCard
                    if manager.configs.isEmpty {
                        emptyStateCard
                    } else {
                        cameraList
                    }
                }
                .padding(theme.grid.cardPadding)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String(localized: "cameraSetup.title"))
                    .dsFont(.title2, weight: .bold)
                    .lineLimit(1)
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    editingCamera = nil
                    showEditor = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel(String(localized: "cameraSetup.add.title"))
            }
        }
        .sheet(isPresented: $showEditor) {
            CameraEditorView(
                manager: manager,
                camera: editingCamera
            )
        }
        .sheet(item: $selectedDiscovery) { discovery in
            CameraQuickAddSheet(manager: manager, discovery: discovery)
        }
        .alert(String(localized: "cameraSetup.delete.title"), isPresented: $showDeleteConfirmation) {
            Button(String(localized: "cameraSetup.delete.confirm"), role: .destructive) {
                if let pendingDelete {
                    manager.deleteCamera(pendingDelete)
                }
            }
            Button(String(localized: "common.cancel"), role: .cancel) {}
        } message: {
            Text(String(localized: "cameraSetup.delete.message"))
        }
        .alert(String(localized: "common.error.title"), isPresented: errorBinding) {
            Button(String(localized: "common.ok")) { manager.errorMessage = nil }
        } message: {
            Text(manager.errorMessage ?? String(localized: "common.error.fallback"))
        }
        .onAppear {
            manager.configure(modelContext: modelContext)
            manager.loadConfigs()
            discoveryHub.start()
        }
        .onDisappear {
            discoveryHub.stop()
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { manager.errorMessage != nil },
            set: { newValue in
                if !newValue { manager.errorMessage = nil }
            }
        )
    }

    private var emptyStateCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                Text(String(localized: "cameraSetup.empty.title"))
                    .dsFont(.headline, weight: .bold)
                Text(String(localized: "cameraSetup.empty.message"))
                    .dsFont(.body)
                    .foregroundStyle(.secondary)
                Text(String(localized: "cameraSetup.empty.supportedTitle"))
                    .dsFont(.caption, weight: .bold)
                    .foregroundStyle(.secondary)
                StreamingCameraSupportedListView()
                Button {
                    editingCamera = nil
                    showEditor = true
                    hapticFeedback(.selection)
                } label: {
                    Label(String(localized: "cameraSetup.empty.action"), systemImage: "plus.circle.fill")
                        .dsFont(.headline)
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var quickAddCard: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "cameraSetup.quickAdd.title"))
                            .dsFont(.headline, weight: .bold)
                        Text(String(localized: "cameraSetup.quickAdd.subtitle"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        if discoveryHub.isScanning {
                            discoveryHub.stop()
                        } else {
                            discoveryHub.start()
                        }
                        hapticFeedback(.selection)
                    } label: {
                        Text(discoveryHub.isScanning
                             ? String(localized: "cameraSetup.quickAdd.stop")
                             : String(localized: "cameraSetup.quickAdd.scan"))
                            .dsFont(.caption)
                    }
                }

                if discoveryHub.results.isEmpty {
                    Text(String(localized: "cameraSetup.quickAdd.none"))
                        .dsFont(.body)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "cameraSetup.quickAdd.tip.network"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(localized: "cameraSetup.quickAdd.tip.power"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(localized: "cameraSetup.quickAdd.tip.manual"))
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    ForEach(discoveryHub.results) { result in
                        Button {
                            selectedDiscovery = result
                            hapticFeedback(.selection)
                        } label: {
                            HStack(alignment: .top, spacing: theme.grid.listSpacing) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.kind.localizedTitle)
                                        .dsFont(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(result.name)
                                        .dsFont(.headline)
                                    Text(discoveryDetail(result))
                                        .dsFont(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(String(localized: "cameraSetup.quickAdd.action"))
                                    .dsFont(.caption, weight: .bold)
                                    .foregroundStyle(theme.palette.primary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button(String(localized: "cameraSetup.quickAdd.manual")) {
                    editingCamera = nil
                    showEditor = true
                    hapticFeedback(.selection)
                }
                .buttonStyle(.nativeGlassProminent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var cameraList: some View {
        VStack(spacing: theme.grid.listSpacing) {
            ForEach(manager.configs) { camera in
                cameraCard(camera)
            }
        }
    }

    private func cameraCard(_ camera: StreamingCameraConfig) -> some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(camera.name)
                            .dsFont(.headline, weight: .bold)
                        Text(camera.providerType.localizedName)
                            .dsFont(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Menu {
                        Button {
                            editingCamera = camera
                            showEditor = true
                        } label: {
                            Label(String(localized: "cameraSetup.edit.title"), systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            pendingDelete = camera
                            showDeleteConfirmation = true
                        } label: {
                            Label(String(localized: "cameraSetup.delete.action"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.secondary)
                    }
                }

                if let detail = cameraDetail(camera) {
                    Text(detail)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func cameraDetail(_ camera: StreamingCameraConfig) -> String? {
        switch camera.providerType {
        case .rtsp:
            if let urlString = camera.rtspURLString, let url = URL(string: urlString) {
                return url.host ?? urlString
            }
            return camera.rtspURLString
        case .tapo:
            if let host = camera.host {
                if let port = camera.port {
                    return "\(host):\(port)"
                }
                return host
            }
            return nil
        case .homeAssistant:
            return camera.cameraEntityId
        }
    }

    private func discoveryDetail(_ result: StreamingCameraDiscoveryResult) -> String {
        switch result.kind {
        case .homeAssistant:
            if let url = result.suggestedURL {
                return url.host ?? result.host
            }
            return result.host
        case .rtsp:
            if let url = result.suggestedURL {
                return url.host ?? result.host
            }
            return result.host
        case .tapo:
            if let port = result.port {
                return "\(result.host):\(port)"
            }
            return result.host
        }
    }
}

#Preview {
    NavigationStack {
        CameraSetupView()
    }
    .modelContainer(for: [StreamingCameraConfig.self], inMemory: true)
    .environment(AppDependencies())
}
