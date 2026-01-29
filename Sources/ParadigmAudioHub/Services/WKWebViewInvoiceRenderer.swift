import AppKit
import WebKit

final class WKWebViewInvoiceRenderer: NSObject, InvoiceRenderer, WKNavigationDelegate {
    private let templateEngine: InvoiceTemplateEngine
    private var completion: ((Result<URL, Error>) -> Void)?
    private var outputURL: URL?
    private var webView: WKWebView?

    init(templateEngine: InvoiceTemplateEngine = InvoiceTemplateEngine()) {
        self.templateEngine = templateEngine
    }

    func render(invoice: Invoice, to url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        self.completion = completion
        self.outputURL = url

        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .init(x: 0, y: 0, width: 595, height: 842), configuration: config)
        webView.navigationDelegate = self
        self.webView = webView

        do {
            let html = try templateEngine.renderHTML(invoice: invoice)
            let baseURL = Bundle.module.resourceURL?.appendingPathComponent("Templates")
            webView.loadHTMLString(html, baseURL: baseURL)
        } catch {
            completion(.failure(error))
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let outputURL else {
            completion?(.failure(InvoiceRendererError.renderingFailed))
            return
        }

        let printInfo = NSPrintInfo.shared.copy() as? NSPrintInfo ?? NSPrintInfo.shared
        printInfo.jobDisposition = .save
        printInfo.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = outputURL
        printInfo.dictionary()[NSPrintInfo.AttributeKey.paperName] = "iso-a4"
        printInfo.topMargin = 18
        printInfo.bottomMargin = 18
        printInfo.leftMargin = 18
        printInfo.rightMargin = 18

        let printOperation = webView.printOperation(with: printInfo)
        printOperation.showsPrintPanel = false
        printOperation.showsProgressPanel = false

        if printOperation.run() {
            completion?(.success(outputURL))
        } else {
            completion?(.failure(InvoiceRendererError.renderingFailed))
        }
    }
}
