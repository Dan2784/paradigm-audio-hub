import SwiftUI

@main
struct ParadigmAudioHubApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            if store.settings.projectRootPath == nil {
                OnboardingView(store: store)
            } else {
                RootView(store: store)
            }
        }
    }
}
