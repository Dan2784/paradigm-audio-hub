import Foundation

enum ServiceType: String, Codable, CaseIterable, Identifiable {
    case recording
    case mixing
    case mastering

    var id: String { rawValue }
    var displayName: String {
        rawValue.capitalized
    }
}

enum ProjectScope: String, Codable, CaseIterable, Identifiable {
    case single
    case ep
    case album

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .single: return "Single"
        case .ep: return "EP"
        case .album: return "Album"
        }
    }
}

struct Project: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var clientName: String
    var name: String
    var serviceType: ServiceType
    var scope: ProjectScope
    var songTitles: [String]
    var createdAt: Date = Date()
    var createInvoiceOnCreate: Bool = true
    var linkedInvoiceId: UUID?
}
