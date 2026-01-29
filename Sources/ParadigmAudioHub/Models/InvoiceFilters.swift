import Foundation

struct InvoiceFilters {
    var client: String = ""
    var status: InvoiceStatus? = nil
    var issueFrom: Date? = nil
    var issueTo: Date? = nil
    var paidFrom: Date? = nil
    var paidTo: Date? = nil
    var search: String = ""
}
