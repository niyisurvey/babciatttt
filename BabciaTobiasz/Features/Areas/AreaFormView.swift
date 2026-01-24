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
    @State private var selectedColor: Color = DesignSystemTheme.default.palette.coolAccent
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

    private var colorOptions: [Color] {
        [
            theme.palette.coolAccent, theme.palette.success, theme.palette.tertiary,
            theme.palette.primary, theme.palette.secondary,
            theme.palette.warmAccent, theme.palette.warning,
            .mint, .indigo, .pink, .brown, .gray // Keep some as fallback if no token
        ]
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isEditing: Bool {
        area != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()

                ScrollView {
                    VStack(spacing: theme.grid.sectionSpacing) {
                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.basicInfo.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)

                            GlassCardView {
                                VStack(spacing: theme.grid.cardPadding) {
                                    TextField(String(localized: "areaForm.basicInfo.name.placeholder"), text: $name)
                                        .dsFont(.headline)

                                    Divider()

                                    TextField(String(localized: "areaForm.basicInfo.description.placeholder"), text: $description, axis: .vertical)
                                        .dsFont(.body)
                                        .lineLimit(3...6)

                                    Text(String(localized: "areaForm.basicInfo.description.hint"))
                                        .dsFont(.caption2)
                                        .foregroundStyle(theme.palette.textSecondary)
                                }
                            }

                            Text(String(localized: "areaForm.basicInfo.helper"))
                                .dsFont(.caption)
                                .foregroundStyle(theme.palette.textSecondary)
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.appearance.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)
                            Text(String(localized: "areaForm.appearance.helper"))
                                .dsFont(.caption)
                                .foregroundStyle(theme.palette.textSecondary)
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)

                            GlassCardView {
                                VStack(alignment: .leading, spacing: theme.grid.sectionSpacing) {
                                    VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                                        Text(String(localized: "areaForm.appearance.icon"))
                                            .dsFont(.subheadline, weight: .bold)
                                            .foregroundStyle(theme.palette.textSecondary)

                                        iconPicker
                                    }

                                    Divider()

                                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                                        Text(String(localized: "areaForm.appearance.color"))
                                            .dsFont(.subheadline, weight: .bold)
                                            .foregroundStyle(theme.palette.textSecondary)

                                        colorPicker
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.persona.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)

                            if isEditing, let area {
                                GlassCardView {
                                    VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                                        Text(String(localized: "areaForm.persona.readonly.label"))
                                            .dsFont(.caption)
                                            .foregroundStyle(theme.palette.textSecondary)
                                        Text(area.persona.localizedDisplayName)
                                            .dsFont(.headline, weight: .bold)
                                    }
                                }
                            } else {
                                GlassCardView {
                                    VStack(spacing: theme.grid.listSpacing) {
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
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)

                            GlassCardView {
                                VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                                    Text(String(localized: "areaForm.camera.helper"))
                                        .dsFont(.caption)
                                        .foregroundStyle(theme.palette.textSecondary)

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
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)
                            Text(String(localized: "areaForm.reminders.helper"))
                                .dsFont(.caption)
                                .foregroundStyle(theme.palette.textSecondary)
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)

                            if let area {
                                ReminderConfigView(area: area)
                            } else {
                                GlassCardView {
                                    Text(String(localized: "areaForm.reminders.empty"))
                                        .dsFont(.subheadline)
                                        .foregroundStyle(theme.palette.textSecondary)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text(String(localized: "areaForm.preview.title"))
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, theme.grid.cardPaddingTight / 3)

                            GlassCardView {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(String(localized: "areaForm.preview.helper"))
                                        .dsFont(.caption)
                                        .foregroundStyle(theme.palette.textSecondary)
                                    previewCard
                                }
                                .padding(.vertical, theme.grid.cardPaddingTight / 2)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.shape.cardCornerRadius)
                                    .stroke(selectedColor.opacity(theme.elevation.overlayDim), lineWidth: 2)
                            )
                        }
                    }
                    .padding()
                }
            }
            .scrollContentBackground(.hidden)
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
                .liquidGlassSheetBackground()
            }
        }
        .liquidGlassSheetBackground()
    }

    private var iconPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: theme.grid.listSpacing) {
            ForEach(iconOptions, id: \.self) { icon in
                Button {
                    selectedIcon = icon
                } label: {
                    Image(systemName: icon)
                        .font(theme.typography.font(.title2))
                        .foregroundStyle(selectedIcon == icon ? selectedColor : theme.palette.textSecondary)
                        .frame(width: theme.grid.iconLarge, height: theme.grid.iconLarge)
                        .background(
                            selectedIcon == icon ? selectedColor.opacity(theme.elevation.shimmerOpacity) : Color.clear,
                            in: RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.shape.subtleCornerRadius, style: .continuous)
                                .stroke(selectedIcon == icon ? selectedColor : Color.clear, lineWidth: 2)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(format: String(localized: "areaForm.appearance.icon.accessibility"), icon))
            }
        }
    }

    private var colorPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: theme.grid.listSpacing) {
            ForEach(colorOptions, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    RoundedRectangle(cornerRadius: theme.shape.controlCornerRadius, style: .continuous)
                        .fill(color)
                        .frame(width: theme.grid.listSpacing * 3, height: theme.grid.listSpacing * 3)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.shape.controlCornerRadius, style: .continuous)
                                .stroke(theme.palette.primary.opacity(selectedColor == color ? 0.9 : 0), lineWidth: 3)
                                .padding(1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.shape.controlCornerRadius, style: .continuous)
                                .stroke(theme.palette.onPrimary.opacity(selectedColor == color ? 0.8 : 0), lineWidth: 1)
                                .padding(4)
                        )
                        .overlay {
                            if selectedColor == color {
                                Image(systemName: "checkmark")
                                    .dsFont(.caption, weight: .bold)
                                    .foregroundStyle(theme.palette.onPrimary)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var previewCard: some View {
        HStack(spacing: theme.grid.cardPadding) {
            ZStack {
                RoundedRectangle(cornerRadius: theme.shape.controlCornerRadius, style: .continuous)
                    .fill(selectedColor.opacity(theme.elevation.shimmerOpacity))
                    .frame(width: theme.grid.iconError, height: theme.grid.iconError)

                Image(systemName: selectedIcon)
                    .font(theme.typography.font(.title2))
                    .foregroundStyle(selectedColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? String(localized: "areaForm.preview.placeholder") : name)
                    .dsFont(.headline)
                    .foregroundStyle(name.isEmpty ? theme.palette.textSecondary : theme.palette.primary)

                if !description.isEmpty {
                    Text(description)
                        .dsFont(.caption)
                        .foregroundStyle(theme.palette.textSecondary)
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

    private func personaRow(_ persona: BabciaPersona) -> some View {
        Button {
            selectedPersona = persona
        } label: {
            HStack(spacing: theme.grid.listSpacing) {
                VStack(alignment: .leading, spacing: theme.grid.cardPaddingTight / 3) {
                    Text(persona.localizedDisplayName)
                        .dsFont(.headline, weight: .bold)
                    Text(persona.localizedTagline)
                        .dsFont(.caption)
                        .foregroundStyle(theme.palette.textSecondary)
                }

                Spacer()

                Image(systemName: selectedPersona == persona ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(selectedPersona == persona ? selectedColor : theme.palette.textSecondary)
                    .font(theme.typography.font(.title3))
            }
            .padding(.vertical, theme.grid.cardPaddingTight / 3)
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
