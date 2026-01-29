import Foundation

struct InvoiceFiltering {
    static func apply(filters: InvoiceFilters, invoices: [Invoice]) -> [Invoice] {
        invoices.filter { invoice in
            if !filters.client.isEmpty && !invoice.clientName.localizedCaseInsensitiveContains(filters.client) {
                return false
            }
            if let status = filters.status, invoice.status != status {
                return false
            }
            if let issueFrom = filters.issueFrom, invoice.issueDate < issueFrom {
                return false
            }
            if let issueTo = filters.issueTo, invoice.issueDate > issueTo {
                return false
            }
            if let paidFrom = filters.paidFrom {
                guard let paidDate = invoice.paidDate else { return false }
                if paidDate < paidFrom { return false }
            }
            if let paidTo = filters.paidTo {
                guard let paidDate = invoice.paidDate else { return false }
                if paidDate > paidTo { return false }
            }
            if !filters.search.isEmpty {
                let haystack = "\(invoice.number) \(invoice.clientName) \(invoice.projectName)"
                if !haystack.localizedCaseInsensitiveContains(filters.search) {
                    return false
                }
            }
            return true
        }
    }
}
