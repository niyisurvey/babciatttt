import SwiftUI

struct SettingsSheet: View {
    @AppStorage("isGlassMode") private var isGlassMode = true
    @AppStorage("isDarkMode") private var isDarkMode = true
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Appearance") {
                    Toggle("Glass Mode", isOn: $isGlassMode)
                    Toggle("Dark Mode", isOn: $isDarkMode)
                }
                
                Section("About") {
                    LabeledContent("Version", value: "1.0.0 Alpha")
                    LabeledContent("Experiments", value: "70+")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationBackground(.ultraThinMaterial)
    }
}
