import Foundation

protocol InvoiceRenderer {
    func render(invoice: Invoice, to url: URL, completion: @escaping (Result<URL, Error>) -> Void)
}

enum InvoiceRendererError: Error {
    case missingTemplate
    case renderingFailed
}
