import SwiftUI

struct InvoiceDetailView: View {
    @ObservedObject var store: AppStore
    @State private var invoice: Invoice

    init(store: AppStore, invoice: Invoice) {
        self.store = store
        _invoice = State(initialValue: invoice)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invoice \(invoice.number)")
                .font(.title2)
            HStack {
                TextField("Client", text: $invoice.clientName)
                TextField("Project", text: $invoice.projectName)
            }
            Picker("Status", selection: $invoice.status) {
                ForEach(InvoiceStatus.allCases) { status in
                    Text(status.displayName).tag(status)
                }
            }
            HStack {
                DatePicker("Issue", selection: $invoice.issueDate, displayedComponents: .date)
                DatePicker("Due", selection: $invoice.dueDate, displayedComponents: .date)
                DatePicker("Sent", selection: bindingDate($invoice.sentDate), displayedComponents: .date)
                DatePicker("Paid", selection: bindingDate($invoice.paidDate), displayedComponents: .date)
            }
            List {
                ForEach($invoice.lineItems) { $item in
                    VStack(alignment: .leading) {
                        TextField("Description", text: $item.description)
                        HStack {
                            Stepper("Qty \(item.quantity)", value: $item.quantity, in: 1...999)
                            TextField("Unit Price", value: $item.unitPrice, formatter: decimalFormatter)
                        }
                        TextField("Notes", text: Binding($item.notes, default: ""))
                    }
                }
            }
            HStack {
                Button("Add Line Item") {
                    invoice.lineItems.append(.init(description: "", quantity: 1, unitPrice: 0, notes: nil))
                }
                Menu("Add Preset") {
                    ForEach(store.presets) { preset in
                        Button(preset.description) {
                            invoice.lineItems.append(.init(description: preset.description, quantity: 1, unitPrice: preset.unitPrice, notes: preset.notes))
                        }
                    }
                }
                .disabled(store.presets.isEmpty)
                Spacer()
                Button("Save") {
                    store.updateInvoice(invoice)
                }
            }
        }
        .padding(24)
        .frame(minWidth: 700, minHeight: 600)
    }

    private var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }

    private func bindingDate(_ date: Binding<Date?>) -> Binding<Date> {
        Binding<Date>(
            get: { date.wrappedValue ?? Date() },
            set: { date.wrappedValue = $0 }
        )
    }
}

private extension Binding where Value == String? {
    init(_ source: Binding<String?>, default defaultValue: String) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
