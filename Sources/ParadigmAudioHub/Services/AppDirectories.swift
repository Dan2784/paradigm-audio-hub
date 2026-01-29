import Foundation

struct AppDirectories {
    static let appSupportFolderName = "ParadigmAudioHub"

    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    var appSupportURL: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return (base ?? URL(fileURLWithPath: NSHomeDirectory())).appendingPathComponent(Self.appSupportFolderName, isDirectory: true)
    }

    var pdfLibraryURL: URL {
        appSupportURL.appendingPathComponent("PDFLibrary", isDirectory: true)
    }

    var dataStoreURL: URL {
        appSupportURL.appendingPathComponent("data.json")
    }

    func ensureDirectoriesExist() throws {
        try fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: pdfLibraryURL, withIntermediateDirectories: true)
    }
}
