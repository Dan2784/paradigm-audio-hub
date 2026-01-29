import Foundation

struct CSVExportService {
    func export(invoices: [Invoice], to url: URL) throws {
        let header = [
            "Invoice Number",
            "Client",
            "Project",
            "Issue Date",
            "Due Date",
            "Sent Date",
            "Paid Date",
            "Status",
            "Subtotal",
            "Total"
        ]

        let formatter = ISO8601DateFormatter()
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "GBP"

        let rows = invoices.map { invoice in
            [
                invoice.number,
                invoice.clientName,
                invoice.projectName,
                formatter.string(from: invoice.issueDate),
                formatter.string(from: invoice.dueDate),
                invoice.sentDate.map { formatter.string(from: $0) } ?? "",
                invoice.paidDate.map { formatter.string(from: $0) } ?? "",
                invoice.status.displayName,
                currencyFormatter.string(from: NSNumber(value: invoice.subtotal)) ?? "£0.00",
                currencyFormatter.string(from: NSNumber(value: invoice.total)) ?? "£0.00"
            ].map { escape($0) }.joined(separator: ",")
        }

        let csv = ([header.joined(separator: ",")] + rows).joined(separator: "\n")
        try csv.write(to: url, atomically: true, encoding: .utf8)
    }

    private func escape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return value
    }
}
