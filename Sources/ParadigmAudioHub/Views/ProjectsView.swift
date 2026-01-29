import SwiftUI

struct ProjectsView: View {
    @ObservedObject var store: AppStore
    @State private var clientName: String = ""
    @State private var projectName: String = ""
    @State private var serviceType: ServiceType = .recording
    @State private var scope: ProjectScope = .single
    @State private var songTitlesText: String = ""
    @State private var createInvoiceNow: Bool = true

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Create Project")
                    .font(.title2)
                TextField("Client", text: $clientName)
                TextField("Project", text: $projectName)
                Picker("Service", selection: $serviceType) {
                    ForEach(ServiceType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                Picker("Scope", selection: $scope) {
                    ForEach(ProjectScope.allCases) { scope in
                        Text(scope.displayName).tag(scope)
                    }
                }
                if scope != .single {
                    TextField("Song titles (one per line)", text: $songTitlesText, axis: .vertical)
                        .lineLimit(4...8)
                }
                Toggle("Create invoice now", isOn: $createInvoiceNow)
                Button("Create Project") {
                    let songs = songTitlesText.split(separator: "\n").map { String($0) }
                    let project = Project(
                        clientName: clientName,
                        name: projectName,
                        serviceType: serviceType,
                        scope: scope,
                        songTitles: songs,
                        createInvoiceOnCreate: createInvoiceNow
                    )
                    store.createProject(project)
                    clientName = ""
                    projectName = ""
                    songTitlesText = ""
                }
                .disabled(clientName.isEmpty || projectName.isEmpty)
            }
            .frame(maxWidth: 420)

            Divider()

            List(store.projects) { project in
                VStack(alignment: .leading) {
                    Text(project.name)
                        .font(.headline)
                    Text(project.clientName)
                        .foregroundColor(.secondary)
                    Text("\(project.serviceType.displayName) • \(project.scope.displayName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding(24)
    }
}
