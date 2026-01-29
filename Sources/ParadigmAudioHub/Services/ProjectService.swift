import Foundation

struct ProjectService {
    let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func createProjectFolders(project: Project, rootURL: URL) throws -> URL {
        let clientFolder = PathSanitizer.sanitize(project.clientName)
        let projectFolder = PathSanitizer.sanitize(project.name)
        let projectURL = rootURL
            .appendingPathComponent(clientFolder, isDirectory: true)
            .appendingPathComponent(projectFolder, isDirectory: true)

        try fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)

        let adminURL = projectURL.appendingPathComponent("01 Admin", isDirectory: true)
        let sourceURL = projectURL.appendingPathComponent("02 Source", isDirectory: true)
        let sessionURL = projectURL.appendingPathComponent("03 Session", isDirectory: true)
        let printsURL = projectURL.appendingPathComponent("04 Prints", isDirectory: true)
        let mastersURL = projectURL.appendingPathComponent("05 Masters", isDirectory: true)
        let deliveryURL = projectURL.appendingPathComponent("06 Delivery", isDirectory: true)
        let revisionsURL = projectURL.appendingPathComponent("07 Revisions", isDirectory: true)

        try fileManager.createDirectory(at: adminURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: adminURL.appendingPathComponent("Invoices", isDirectory: true), withIntermediateDirectories: true)
        try fileManager.createDirectory(at: sourceURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: sessionURL, withIntermediateDirectories: true)
        if project.serviceType != .mastering {
            try fileManager.createDirectory(at: printsURL, withIntermediateDirectories: true)
        }
        try fileManager.createDirectory(at: mastersURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: deliveryURL, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: revisionsURL, withIntermediateDirectories: true)

        if project.scope != .single && !project.songTitles.isEmpty {
            try createSongFolders(songTitles: project.songTitles, in: sourceURL)
            try createSongFolders(songTitles: project.songTitles, in: deliveryURL)
        }

        return projectURL
    }

    private func createSongFolders(songTitles: [String], in parentURL: URL) throws {
        for (index, title) in songTitles.enumerated() {
            let number = String(format: "%02d", index + 1)
            let safeTitle = PathSanitizer.sanitize(title)
            let folderName = "\(number) - \(safeTitle)"
            let folderURL = parentURL.appendingPathComponent(folderName, isDirectory: true)
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
    }
}
