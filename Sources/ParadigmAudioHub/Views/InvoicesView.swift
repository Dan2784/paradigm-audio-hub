import AppKit
import SwiftUI

struct InvoicesView: View {
    @ObservedObject var store: AppStore
    @State private var filters = InvoiceFilters()
    @State private var selection = Set<Invoice.ID>()
    @State private var showingDetail = false

    private let exportService = InvoiceExportService()
    private let csvExportService = CSVExportService()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invoices Explorer")
                .font(.title2)
            filterBar
            Table(filteredInvoices, selection: $selection) {
                TableColumn("Invoice") { invoice in
                    Text(invoice.number)
                }
                TableColumn("Client") { invoice in
                    Text(invoice.clientName)
                }
                TableColumn("Project") { invoice in
                    Text(invoice.projectName)
                }
                TableColumn("Status") { invoice in
                    Text(invoice.status.displayName)
                }
            }
            .frame(minHeight: 400)
            HStack {
                Button("Open Detail") {
                    showingDetail = true
                }
                .disabled(selectedInvoice == nil)
                Button("Export PDF") {
                    if let invoice = selectedInvoice {
                        exportService.export(invoice: invoice) { _ in }
                    }
                }
                .disabled(selectedInvoice == nil)
                Button("Reveal PDF") {
                    if let invoice = selectedInvoice {
                        revealPDF(invoice: invoice)
                    }
                }
                .disabled(selectedInvoice == nil)
                Menu("Change Status") {
                    ForEach(InvoiceStatus.allCases) { status in
                        Button(status.displayName) {
                            guard var invoice = selectedInvoice else { return }
                            invoice.status = status
                            store.updateInvoice(invoice)
                        }
                    }
                }
                .disabled(selectedInvoice == nil)
                Button("Export CSV") {
                    exportCSV()
                }
            }
        }
        .padding(24)
        .sheet(isPresented: $showingDetail) {
            if let invoice = selectedInvoice {
                InvoiceDetailView(store: store, invoice: invoice)
            }
        }
    }

    private var selectedInvoice: Invoice? {
        guard let id = selection.first else { return nil }
        return store.invoices.first { $0.id == id }
    }

    private var filterBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("Search", text: $filters.search)
                TextField("Client", text: $filters.client)
                Picker("Status", selection: $filters.status) {
                    Text("All").tag(InvoiceStatus?.none)
                    ForEach(InvoiceStatus.allCases) { status in
                        Text(status.displayName).tag(InvoiceStatus?.some(status))
                    }
                }
            }
            HStack {
                OptionalDatePicker(title: "Issue From", date: $filters.issueFrom)
                OptionalDatePicker(title: "Issue To", date: $filters.issueTo)
                OptionalDatePicker(title: "Paid From", date: $filters.paidFrom)
                OptionalDatePicker(title: "Paid To", date: $filters.paidTo)
            }
            .font(.caption)
        }
    }

    private var filteredInvoices: [Invoice] {
        InvoiceFiltering.apply(filters: filters, invoices: store.invoices)
    }

    private func revealPDF(invoice: Invoice) {
        let directories = AppDirectories()
        let fileName = InvoiceExportService().fileNameFor(invoice: invoice)
        let url = directories.pdfLibraryURL.appendingPathComponent(fileName)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    private func exportCSV() {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["csv"]
        panel.nameFieldStringValue = "invoices.csv"
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                try csvExportService.export(invoices: filteredInvoices, to: url)
            } catch {
                NSLog("CSV export failed: \(error)")
            }
        }
    }
}
