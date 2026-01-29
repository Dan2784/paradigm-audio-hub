import AppKit
import Foundation

final class InvoiceExportService {
    private let directories: AppDirectories
    private let renderer: InvoiceRenderer

    init(directories: AppDirectories = AppDirectories(), renderer: InvoiceRenderer = WKWebViewInvoiceRenderer()) {
        self.directories = directories
        self.renderer = renderer
    }

    func export(invoice: Invoice, completion: @escaping (Result<URL, Error>) -> Void) {
        do {
            try directories.ensureDirectoriesExist()
        } catch {
            completion(.failure(error))
            return
        }

        let fileName = fileNameFor(invoice: invoice)
        let libraryURL = directories.pdfLibraryURL.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: libraryURL.path) {
            try? FileManager.default.removeItem(at: libraryURL)
        }

        renderer.render(invoice: invoice, to: libraryURL) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.promptSaveCopy(of: libraryURL, suggestedName: fileName)
                }
                completion(result)
            case .failure:
                completion(result)
            }
        }
    }

    func fileNameFor(invoice: Invoice) -> String {
        let client = PathSanitizer.sanitize(invoice.clientName)
        let project = PathSanitizer.sanitize(invoice.projectName)
        return "invoice \(invoice.number) | \(client) - \(project).pdf"
    }

    private func promptSaveCopy(of url: URL, suggestedName: String) {
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["pdf"]
        panel.nameFieldStringValue = suggestedName
        panel.canCreateDirectories = true
        panel.begin { response in
            guard response == .OK, let destination = panel.url else { return }
            do {
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.copyItem(at: url, to: destination)
            } catch {
                NSLog("Failed to save copy: \(error)")
            }
        }
    }
}
