import SwiftUI

struct RootView: View {
    @ObservedObject var store: AppStore

    var body: some View {
        TabView {
            ProjectsView(store: store)
                .tabItem { Label("Projects", systemImage: "folder") }
            InvoicesView(store: store)
                .tabItem { Label("Invoices", systemImage: "doc.text") }
            AnalyticsView(store: store)
                .tabItem { Label("Analytics", systemImage: "chart.bar.xaxis") }
            SettingsView(store: store)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .frame(minWidth: 1080, minHeight: 720)
    }
}
