import Foundation

struct InvoiceTemplateEngine {
    let bundle: Bundle

    init(bundle: Bundle = .module) {
        self.bundle = bundle
    }

    func renderHTML(invoice: Invoice) throws -> String {
        guard let htmlURL = bundle.url(forResource: "invoice", withExtension: "html", subdirectory: "Templates") else {
            throw InvoiceRendererError.missingTemplate
        }
        let htmlTemplate = try String(contentsOf: htmlURL)

        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "GBP"
        currencyFormatter.maximumFractionDigits = 2

        let logoURL = bundle.url(forResource: "paradigm-logo", withExtension: "svg", subdirectory: "Assets")

        let clientAddressBlock: String
        if let billing = invoice.clientBillingAddress, !billing.isEmpty {
            clientAddressBlock = "<div class=\"party-line subtle\">\(escapeHTML(billing).replacingOccurrences(of: "\n", with: "<br/>"))</div>"
        } else {
            clientAddressBlock = ""
        }

        let notesBlock: String
        if let notes = invoice.notes, !notes.isEmpty {
            notesBlock = escapeHTML(notes).replacingOccurrences(of: "\n", with: "<br/>")
        } else {
            notesBlock = ""
        }

        let bankDetailsBlock: String
        if let bank = invoice.bankDetails, !bank.isEmpty {
            bankDetailsBlock = escapeHTML(bank).replacingOccurrences(of: "\n", with: "<br/>")
        } else {
            bankDetailsBlock = ""
        }

        let lineItemsRows = invoice.lineItems.map { item -> String in
            let total = currencyFormatter.string(from: NSNumber(value: item.total)) ?? "£0.00"
            let rate = currencyFormatter.string(from: NSNumber(value: item.unitPrice)) ?? "£0.00"
            let notesHTML: String
            if let notes = item.notes, !notes.isEmpty {
                notesHTML = "<div class=\"desc-note\">\(escapeHTML(notes))</div>"
            } else {
                notesHTML = ""
            }
            return """
            <tr>
              <td class=\"col-desc\"><div class=\"desc-main\">\(escapeHTML(item.description))</div>\(notesHTML)</td>
              <td class=\"col-qty\">\(item.quantity)</td>
              <td class=\"col-rate\">\(rate)</td>
              <td class=\"col-total\">\(total)</td>
            </tr>
            """
        }.joined(separator: "\n")

        let footerLeft = "invoice \(invoice.number)"
        let footerRight = "\(PathSanitizer.sanitize(invoice.clientName)) - \(PathSanitizer.sanitize(invoice.projectName))"

        let replacements: [String: String] = [
            "{{invoice_number}}": escapeHTML(invoice.number),
            "{{status}}": escapeHTML(invoice.status.displayName),
            "{{status_slug}}": escapeHTML(invoice.status.slug),
            "{{issue_date}}": escapeHTML(formatter.string(from: invoice.issueDate)),
            "{{due_date}}": escapeHTML(formatter.string(from: invoice.dueDate)),
            "{{client_name}}": escapeHTML(invoice.clientName),
            "{{client_email}}": escapeHTML(invoice.clientEmail ?? ""),
            "{{client_billing_address_block}}": clientAddressBlock,
            "{{project_name}}": escapeHTML(invoice.projectName),
            "{{project_ref}}": escapeHTML(invoice.projectReference ?? ""),
            "{{line_items_rows}}": lineItemsRows,
            "{{notes_block}}": notesBlock,
            "{{bank_details_block}}": bankDetailsBlock,
            "{{subtotal}}": currencyFormatter.string(from: NSNumber(value: invoice.subtotal)) ?? "£0.00",
            "{{total}}": currencyFormatter.string(from: NSNumber(value: invoice.total)) ?? "£0.00",
            "{{footer_left}}": escapeHTML(footerLeft),
            "{{footer_right}}": escapeHTML(footerRight),
            "{{business_email}}": "studio@paradigmaudio.uk",
            "{{business_website}}": "paradigmaudio.uk",
            "{{logo_src}}": logoURL?.absoluteString ?? ""
        ]

        return replacements.reduce(htmlTemplate) { partial, replacement in
            partial.replacingOccurrences(of: replacement.key, with: replacement.value)
        }
    }

    private func escapeHTML(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}
