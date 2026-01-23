//
//  ReminderConfigView.swift
//  BabciaTobiasz
//

import SwiftUI
import SwiftData

struct ReminderConfigView: View {
    let area: Area

    @Environment(\.appDependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @Query private var configs: [ReminderConfig]

    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSaveToast = false

    init(area: Area) {
        self.area = area
        let areaId = area.id
        _configs = Query(filter: #Predicate<ReminderConfig> { $0.areaId == areaId })
    }

    var body: some View {
        GlassCardView {
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "reminders.helper"))
                    .dsFont(.caption)
                    .foregroundStyle(.secondary)

                if let config = configs.first {
                    ReminderConfigEditor(
                        area: area,
                        config: config,
                        scheduler: dependencies.services.reminders,
                        onSave: showSavedToast,
                        onError: { message in
                            errorMessage = message
                            showError = true
                        }
                    )
                } else {
                    emptyState
                }
            }
        }
        .alert(String(localized: "reminders.alert.title"), isPresented: $showError) {
            Button(String(localized: "common.ok"), role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .overlay(alignment: .bottom) {
            if showSaveToast {
                ToastBannerView(
                    message: String(localized: "reminders.toast.saved"),
                    actionTitle: nil,
                    onAction: nil,
                    onDismiss: { showSaveToast = false }
                )
                .padding(.vertical, 6)
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "reminders.empty.message"))
                .dsFont(.subheadline)
                .foregroundStyle(.secondary)

            Button(String(localized: "reminders.empty.action")) {
                createConfig()
                hapticFeedback(.selection)
            }
            .dsFont(.headline, weight: .bold)
            .buttonStyle(.nativeGlassProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private func showSavedToast() {
        withAnimation(.easeInOut(duration: 0.2)) {
            showSaveToast = true
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.5))
            withAnimation(.easeInOut(duration: 0.2)) {
                showSaveToast = false
            }
        }
    }

    private func createConfig() {
        let config = ReminderConfig(area: area)
        modelContext.insert(config)
        do {
            try modelContext.save()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

private struct ReminderConfigEditor: View {
    let area: Area
    @Bindable var config: ReminderConfig
    let scheduler: ReminderSchedulerProtocol
    let onSave: () -> Void
    let onError: (String) -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dsTheme) private var theme

    private let defaultTimes: [Date] = [
        Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date(),
        Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) ?? Date(),
        Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.grid.listSpacing) {
            Toggle(String(localized: "reminders.editor.enable"), isOn: bindingForEnabled())
                .dsFont(.headline)

            Divider()

            ForEach(0..<ReminderConfig.maxSlots, id: \.self) { index in
                reminderSlotRow(index)
                if index < ReminderConfig.maxSlots - 1 {
                    Divider()
                }
            }

            Text(String(localized: "reminders.editor.footer"))
                .dsFont(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func reminderSlotRow(_ index: Int) -> some View {
        let enabledBinding = bindingForSlotEnabled(index)
        let timeBinding = bindingForSlotTime(index)

        return HStack {
            Toggle(String(format: String(localized: "reminders.editor.slot"), index + 1), isOn: enabledBinding)
                .dsFont(.subheadline, weight: .bold)

            Spacer()

            DatePicker(
                "",
                selection: timeBinding,
                displayedComponents: [.hourAndMinute]
            )
            .labelsHidden()
            .disabled(!enabledBinding.wrappedValue || !config.isEnabled)
        }
    }

    private func bindingForEnabled() -> Binding<Bool> {
        Binding(
            get: { config.isEnabled },
            set: { newValue in
                config.isEnabled = newValue
                saveAndSchedule()
            }
        )
    }

    private func bindingForSlotEnabled(_ index: Int) -> Binding<Bool> {
        Binding(
            get: { config.slotTimes[index] != nil },
            set: { isEnabled in
                let time = isEnabled ? (config.slotTimes[index] ?? defaultTimes[index]) : nil
                config.updateSlot(index, time: time)
                saveAndSchedule()
            }
        )
    }

    private func bindingForSlotTime(_ index: Int) -> Binding<Date> {
        Binding(
            get: { config.slotTimes[index] ?? defaultTimes[index] },
            set: { newValue in
                config.updateSlot(index, time: newValue)
                saveAndSchedule()
            }
        )
    }

    private func saveAndSchedule() {
        do {
            try modelContext.save()
        } catch {
            onError(error.localizedDescription)
        }

        let areaId = area.id
        let snapshot = config.snapshot
        Task {
            do {
                try await scheduler.schedule(for: areaId, config: snapshot)
                onSave()
            } catch let error as ReminderError {
                onError(error.localizedDescription)
            } catch {
                onError(error.localizedDescription)
            }
        }
    }
}
