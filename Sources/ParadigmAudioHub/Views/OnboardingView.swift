import AppKit
import SwiftUI

struct OnboardingView: View {
    @ObservedObject var store: AppStore
    @State private var selectedPath: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to ParadigmAudioHub")
                .font(.largeTitle)
            Text("Choose a project root folder to store client projects.")
                .foregroundColor(.secondary)
            HStack {
                TextField("Project root", text: $selectedPath)
                    .frame(width: 320)
                Button("Choose…") {
                    chooseFolder()
                }
            }
            Button("Continue") {
                let url = URL(fileURLWithPath: selectedPath)
                store.setProjectRoot(url: url)
            }
            .disabled(selectedPath.isEmpty)
        }
        .padding(40)
        .frame(minWidth: 520, minHeight: 320)
    }

    private func chooseFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            selectedPath = url.path
        }
    }
}
