import AppKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: AppStore
    @State private var newPresetDescription: String = ""
    @State private var newPresetPrice: Double = 0
    @State private var newPresetNotes: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.title2)
            HStack {
                Text("Project Root")
                    .frame(width: 120, alignment: .leading)
                Text(store.settings.projectRootPath ?? "Not set")
                Spacer()
                Button("Change") {
                    chooseFolder()
                }
            }
            Divider()
            Text("Line Item Presets")
                .font(.headline)
            HStack {
                TextField("Description", text: $newPresetDescription)
                TextField("Unit Price", value: $newPresetPrice, formatter: decimalFormatter)
                TextField("Notes", text: $newPresetNotes)
                Button("Add") {
                    let preset = InvoicePreset(description: newPresetDescription, unitPrice: newPresetPrice, notes: newPresetNotes.isEmpty ? nil : newPresetNotes)
                    store.addPreset(preset)
                    newPresetDescription = ""
                    newPresetPrice = 0
                    newPresetNotes = ""
                }
                .disabled(newPresetDescription.isEmpty)
            }
            List {
                ForEach(store.presets) { preset in
                    VStack(alignment: .leading) {
                        Text(preset.description)
                        Text("£\(preset.unitPrice)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .contextMenu {
                        Button("Delete") {
                            store.deletePreset(preset)
                        }
                    }
                }
            }
        }
        .padding(24)
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            store.setProjectRoot(url: url)
        }
    }

    private var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }
}
