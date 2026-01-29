import Foundation
import Combine

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var settings: AppSettings
    @Published private(set) var projects: [Project]
    @Published private(set) var invoices: [Invoice]
    @Published private(set) var presets: [InvoicePreset]

    private let dataStore: DataStore
    private let projectService: ProjectService

    init(dataStore: DataStore = DataStore(), projectService: ProjectService = ProjectService()) {
        self.dataStore = dataStore
        self.projectService = projectService
        self.settings = dataStore.data.settings
        self.projects = dataStore.data.projects
        self.invoices = dataStore.data.invoices
        self.presets = dataStore.data.presets

        dataStore.$data
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.settings = data.settings
                self?.projects = data.projects
                self?.invoices = data.invoices
                self?.presets = data.presets
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    func setProjectRoot(url: URL) {
        dataStore.update { data in
            data.settings.projectRootPath = url.path
        }
    }

    func createProject(_ project: Project) {
        guard let rootPath = settings.projectRootPath else { return }
        do {
            let rootURL = URL(fileURLWithPath: rootPath)
            _ = try projectService.createProjectFolders(project: project, rootURL: rootURL)
            dataStore.update { data in
                var newProject = project
                if newProject.createInvoiceOnCreate {
                    let invoiceNumber = InvoiceNumbering.format(prefix: data.settings.invoicePrefix, padding: data.settings.invoicePadding, number: data.settings.nextInvoiceNumber)
                    data.settings.nextInvoiceNumber += 1
                    let invoice = Invoice(
                        number: invoiceNumber,
                        clientName: project.clientName,
                        clientEmail: nil,
                        clientBillingAddress: nil,
                        projectName: project.name,
                        projectReference: nil,
                        issueDate: Date(),
                        dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date(),
                        sentDate: nil,
                        paidDate: nil,
                        status: .draft,
                        lineItems: [],
                        notes: nil,
                        bankDetails: nil
                    )
                    newProject.linkedInvoiceId = invoice.id
                    data.invoices.append(invoice)
                }
                data.projects.append(newProject)
            }
        } catch {
            NSLog("Failed to create project folders: \(error)")
        }
    }

    func addInvoice(_ invoice: Invoice) {
        dataStore.update { data in
            data.invoices.append(invoice)
        }
    }

    func updateInvoice(_ invoice: Invoice) {
        dataStore.update { data in
            guard let index = data.invoices.firstIndex(where: { $0.id == invoice.id }) else { return }
            data.invoices[index] = invoice
        }
    }

    func addPreset(_ preset: InvoicePreset) {
        dataStore.update { data in
            data.presets.append(preset)
        }
    }

    func deletePreset(_ preset: InvoicePreset) {
        dataStore.update { data in
            data.presets.removeAll { $0.id == preset.id }
        }
    }
}
