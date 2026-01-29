import Foundation

struct AppData: Codable {
    var settings: AppSettings
    var projects: [Project]
    var invoices: [Invoice]
    var presets: [InvoicePreset]

    static let empty = AppData(settings: .defaultSettings, projects: [], invoices: [], presets: [])
}
