import Foundation

struct InvoiceNumbering {
    static func format(prefix: String, padding: Int, number: Int) -> String {
        let formatted = String(format: "%0*d", padding, number)
        return "\(prefix)\(formatted)"
    }
}
