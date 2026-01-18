//
//  AreaFormView.swift
//  BabciaTobiasz
//

import SwiftUI

/// Form view for adding or editing an area.
struct AreaFormView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var viewModel: AreaViewModel
    let area: Area?
    @Environment(\.dsTheme) private var theme

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedIcon: String = "square.grid.2x2.fill"
    @State private var selectedColor: Color = .teal
    @State private var selectedPersona: BabciaPersona = .classic
    @State private var selectedCameraId: UUID?
    @State private var showCameraSetup = false
    @State private var streamingManager = StreamingCameraManager()

    private let iconOptions = [
        "square.grid.2x2.fill", "bed.double.fill", "cup.and.saucer.fill", "fork.knife",
        "sofa.fill", "lamp.desk.fill", "sink.fill", "washer.fill",
        "leaf.fill", "star.fill", "heart.fill", "sparkles",
        "books.vertical.fill", "tv.fill", "gamecontroller.fill", "pencil.and.ruler.fill",
        "door.left.hand.open", "figure.walk", "music.note.house.fill", "car.fill"
    ]

    private let colorOptions: [Color] = [
        .teal, .green, .mint, .cyan, .blue, .indigo,
        .purple, .pink, .orange, .yellow, .brown, .gray
    ]

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isEditing: Bool {
        area != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient

                ScrollView {
                    VStack(spacing: theme.grid.sectionSpacing) {
                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.basicInfo.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                VStack(spacing: 16) {
                                    TextField(String(localized: "areaForm.basicInfo.name.placeholder"), text: $name)
                                        .dsFont(.headline)

                                    Divider()

                                    TextField(String(localized: "areaForm.basicInfo.description.placeholder"), text: $description, axis: .vertical)
                                        .dsFont(.body)
                                        .lineLimit(3...6)

                                    Text(String(localized: "areaForm.basicInfo.description.hint"))
                                        .dsFont(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Text(String(localized: "areaForm.basicInfo.helper"))
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.appearance.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                VStack(alignment: .leading, spacing: 20) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(String(localized: "areaForm.appearance.icon"))
                                            .dsFont(.subheadline, weight: .bold)
                                            .foregroundStyle(.secondary)

                                        iconPicker
                                    }

                                    Divider()

                                    VStack(alignment: .leading, spacing: 12) {
                                        Text(String(localized: "areaForm.appearance.color"))
                                            .dsFont(.subheadline, weight: .bold)
                                            .foregroundStyle(.secondary)

                                        colorPicker
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.persona.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            if isEditing, let area {
                                GlassCardView {
                                    VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                                        Text(String(localized: "areaForm.persona.readonly.label"))
                                            .dsFont(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(area.persona.localizedDisplayName)
                                            .dsFont(.headline, weight: .bold)
                                    }
                                }
                            } else {
                                GlassCardView {
                                    VStack(spacing: 12) {
                                        ForEach(BabciaPersona.allCases) { persona in
                                            personaRow(persona)
                                            if persona != BabciaPersona.allCases.last {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.camera.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(String(localized: "areaForm.camera.helper"))
                                        .dsFont(.caption)
                                        .foregroundStyle(.secondary)

                                    if streamingManager.configs.isEmpty {
                                        Button {
                                            showCameraSetup = true
                                            hapticFeedback(.selection)
                                        } label: {
                                            Label(String(localized: "areaForm.camera.emptyAction"), systemImage: "plus.circle.fill")
                                                .dsFont(.headline)
                                        }
                                        .buttonStyle(.nativeGlassProminent)
                                    } else {
                                        Picker(String(localized: "areaForm.camera.picker.title"), selection: $selectedCameraId) {
                                            Text(String(localized: "areaForm.camera.none"))
                                                .tag(UUID?.none)
                                            ForEach(streamingManager.configs) { config in
                                                Text(config.name)
                                                    .tag(UUID?.some(config.id))
                                            }
                                        }
                                        .pickerStyle(.menu)

                                        Button {
                                            showCameraSetup = true
                                            hapticFeedback(.selection)
                                        } label: {
                                            Label(String(localized: "areaForm.camera.manage"), systemImage: "camera.fill")
                                                .dsFont(.subheadline, weight: .bold)
                                        }
                                        .buttonStyle(.nativeGlass)
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.reminders.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)
                            Text(String(localized: "areaForm.reminders.helper"))
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)

                            if let area {
                                ReminderConfigView(area: area)
                            } else {
                                GlassCardView {
                                    Text(String(localized: "areaForm.reminders.empty"))
                                        .dsFont(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.preview.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(String(localized: "areaForm.preview.helper"))
                                        .dsFont(.caption)
                                        .foregroundStyle(.secondary)
                                    previewCard
                                }
                                .padding(.vertical, 6)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius)
                                    .stroke(selectedColor.opacity(0.5), lineWidth: 2)
                            )
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
                    Text(isEditing ? String(localized: "areaForm.toolbar.editTitle") : String(localized: "areaForm.toolbar.newTitle"))
                        .dsFont(.headline, weight: .bold)
                        .lineLimit(1)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "common.cancel")) {
                        dismiss()
                    }
                    .dsFont(.headline)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? String(localized: "common.save") : String(localized: "common.add")) {
                        saveArea()
                    }
                    .dsFont(.headline, weight: .bold)
                    .disabled(!isValid)
                }
            }
            .onAppear { loadExistingData() }
            .sheet(isPresented: $showCameraSetup) {
                NavigationStack {
                    CameraSetupView()
                }
            }
        }
    }

    private var iconPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(iconOptions, id: \.self) { icon in
                Button {
                    selectedIcon = icon
                } label: {
                    Image(systemName: icon)
                        .font(.system(size: theme.grid.iconTitle2))
                        .foregroundStyle(selectedIcon == icon ? selectedColor : .secondary)
                        .frame(width: 44, height: 44)
                        .background(
                            selectedIcon == icon ? selectedColor.opacity(0.2) : Color.clear,
                            in: Circle()
                        )
                        .overlay(
                            Circle()
                                .stroke(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(format: String(localized: "areaForm.appearance.icon.accessibility"), icon))
            }
        }
    }

    private var colorPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
            ForEach(colorOptions, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    Circle()
                        .fill(color)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(theme.palette.primary.opacity(selectedColor == color ? 0.9 : 0), lineWidth: 3)
                                .padding(1)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(selectedColor == color ? 0.8 : 0), lineWidth: 1)
                                .padding(4)
                        )
                        .overlay {
                            if selectedColor == color {
                                Image(systemName: "checkmark")
                                    .dsFont(.caption, weight: .bold)
                                    .foregroundStyle(.white)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var previewCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(selectedColor.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: selectedIcon)
                    .font(.system(size: theme.grid.iconTitle2))
                    .foregroundStyle(selectedColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? String(localized: "areaForm.preview.placeholder") : name)
                    .dsFont(.headline)
                    .foregroundStyle(name.isEmpty ? .secondary : .primary)

                if !description.isEmpty {
                    Text(description)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }

    private func loadExistingData() {
        streamingManager.configure(modelContext: modelContext)
        streamingManager.loadConfigs()
        guard let area = area else { return }

        name = area.name
        description = area.areaDescription ?? ""
        selectedIcon = area.iconName
        selectedColor = area.color
        selectedPersona = area.persona
        selectedCameraId = area.streamingCameraId
    }

    private func saveArea() {
        Task {
            if let area = area {
                area.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                area.areaDescription = description.isEmpty ? nil : description
                area.iconName = selectedIcon
                area.colorHex = selectedColor.hexString
                area.persona = selectedPersona
                area.streamingCameraId = selectedCameraId

                await viewModel.updateArea(area)
            } else {
                await viewModel.createArea(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.isEmpty ? nil : description,
                    iconName: selectedIcon,
                    colorHex: selectedColor.hexString,
                    dreamImageName: nil,
                    persona: selectedPersona,
                    streamingCameraId: selectedCameraId
                )
            }

            dismiss()
        }
    }

    private var backgroundGradient: some View {
        TimelineView(.animation(minimumInterval: theme.motion.meshAnimationInterval)) { timeline in
            MeshGradient(
                width: 3,
                height: 3,
                points: animatedMeshPoints(for: timeline.date),
                colors: [
                    selectedColor.opacity(0.15),
                    theme.palette.secondary.opacity(0.1),
                    selectedColor.opacity(0.1),
                    theme.palette.tertiary.opacity(0.15),
                    selectedColor.opacity(0.2),
                    theme.palette.primary.opacity(0.1),
                    selectedColor.opacity(0.1),
                    theme.palette.secondary.opacity(0.15),
                    selectedColor.opacity(0.15)
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

    private func personaRow(_ persona: BabciaPersona) -> some View {
        Button {
            selectedPersona = persona
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(persona.localizedDisplayName)
                        .dsFont(.headline, weight: .bold)
                    Text(persona.localizedTagline)
                        .dsFont(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: selectedPersona == persona ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedPersona == persona ? selectedColor : .secondary)
                    .dsFont(.title3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview("New Area") {
    AreaFormView(viewModel: AreaViewModel(), area: nil)
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self, StreamingCameraConfig.self], inMemory: true)
        .environment(AppDependencies())
}

#Preview("Edit Area") {
    AreaFormView(viewModel: AreaViewModel(), area: Area.sampleAreas[0])
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self, StreamingCameraConfig.self], inMemory: true)
        .environment(AppDependencies())
}
