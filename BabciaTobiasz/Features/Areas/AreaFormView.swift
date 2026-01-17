//
//  AreaFormView.swift
//  BabciaTobiasz
//

import SwiftUI

/// Form view for adding or editing an area.
struct AreaFormView: View {

    @Environment(\.dismiss) private var dismiss

    @Bindable var viewModel: AreaViewModel
    let area: Area?
    @Environment(\.dsTheme) private var theme

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedIcon: String = "square.grid.2x2.fill"
    @State private var selectedColor: Color = .teal
    @State private var selectedPersona: BabciaPersona = .classic

    private let iconOptions = [
        "square.grid.2x2.fill", "bed.double.fill", "cup.and.saucer.fill", "fork.knife",
        "sofa.fill", "lamp.desk.fill", "sink.fill", "washer.fill",
        "leaf.fill", "star.fill", "heart.fill", "sparkles"
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
                            Text("Basic Info")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                VStack(spacing: 16) {
                                    TextField("Area name", text: $name)
                                        .dsFont(.headline)

                                    Divider()

                                    TextField("Description (optional)", text: $description, axis: .vertical)
                                        .dsFont(.body)
                                        .lineLimit(3...6)
                                }
                            }

                            Text("Give your area a memorable name")
                                .dsFont(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 4)
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text("Appearance")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                VStack(alignment: .leading, spacing: 20) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Icon")
                                            .dsFont(.subheadline, weight: .bold)
                                            .foregroundStyle(.secondary)

                                        iconPicker
                                    }

                                    Divider()

                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Color")
                                            .dsFont(.subheadline, weight: .bold)
                                            .foregroundStyle(.secondary)

                                        colorPicker
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text("Persona")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

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

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text("Reminders")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            if let area {
                                ReminderConfigView(area: area)
                            } else {
                                GlassCardView {
                                    Text("Create the area first to enable reminders.")
                                        .dsFont(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
                            Text("Preview")
                                .dsFont(.headline, weight: .bold)
                                .padding(.horizontal, 4)

                            GlassCardView {
                                previewCard
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
                    Text(isEditing ? "Edit Area" : "New Area")
                        .dsFont(.headline, weight: .bold)
                        .lineLimit(1)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .dsFont(.headline)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        saveArea()
                    }
                    .dsFont(.headline, weight: .bold)
                    .disabled(!isValid)
                }
            }
            .onAppear { loadExistingData() }
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
                .accessibilityLabel("Icon: \(icon)")
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
                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                .padding(2)
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
                Text(name.isEmpty ? "Area name" : name)
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
        guard let area = area else { return }

        name = area.name
        description = area.areaDescription ?? ""
        selectedIcon = area.iconName
        selectedColor = area.color
        selectedPersona = area.persona
    }

    private func saveArea() {
        Task {
            if let area = area {
                area.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                area.areaDescription = description.isEmpty ? nil : description
                area.iconName = selectedIcon
                area.colorHex = selectedColor.hexString
                area.persona = selectedPersona

                await viewModel.updateArea(area)
            } else {
                await viewModel.createArea(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.isEmpty ? nil : description,
                    iconName: selectedIcon,
                    colorHex: selectedColor.hexString,
                    dreamImageName: nil,
                    persona: selectedPersona
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
                    Text(persona.displayName)
                        .dsFont(.headline, weight: .bold)
                    Text(persona.tagline)
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
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self], inMemory: true)
        .environment(AppDependencies())
}

#Preview("Edit Area") {
    AreaFormView(viewModel: AreaViewModel(), area: Area.sampleAreas[0])
        .modelContainer(for: [Area.self, AreaBowl.self, CleaningTask.self, TaskCompletionEvent.self, Session.self, User.self, ReminderConfig.self], inMemory: true)
        .environment(AppDependencies())
}
