import Foundation

enum InvoiceStatus: String, Codable, CaseIterable, Identifiable {
    case draft
    case sent
    case paid
    case overdue
    case cancelled

    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var slug: String { rawValue }
}

struct InvoiceLineItem: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var description: String
    var quantity: Int
    var unitPrice: Double
    var notes: String?

    var total: Double {
        Double(quantity) * unitPrice
    }
}

struct Invoice: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var number: String
    var clientName: String
    var clientEmail: String?
    var clientBillingAddress: String?
    var projectName: String
    var projectReference: String?
    var issueDate: Date
    var dueDate: Date
    var sentDate: Date?
    var paidDate: Date?
    var status: InvoiceStatus
    var lineItems: [InvoiceLineItem]
    var notes: String?
    var bankDetails: String?

    var subtotal: Double {
        lineItems.reduce(0) { $0 + $1.total }
    }

    var total: Double {
        subtotal
    }
}

struct InvoicePreset: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var description: String
    var unitPrice: Double
    var notes: String?
}
