import Foundation

struct AppSettings: Codable {
    var projectRootPath: String?
    var invoicePrefix: String
    var invoicePadding: Int
    var nextInvoiceNumber: Int

    static let defaultSettings = AppSettings(projectRootPath: nil, invoicePrefix: "PA-", invoicePadding: 4, nextInvoiceNumber: 1)
}
