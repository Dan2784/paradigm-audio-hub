import Foundation
import Combine

final class DataStore: ObservableObject {
    @Published private(set) var data: AppData

    private let directories: AppDirectories
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(directories: AppDirectories = AppDirectories()) {
        self.directories = directories
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601

        if let loaded = try? Self.load(from: directories, decoder: decoder) {
            self.data = loaded
        } else {
            self.data = .empty
        }

        try? directories.ensureDirectoriesExist()
    }

    static func load(from directories: AppDirectories, decoder: JSONDecoder) throws -> AppData {
        let url = directories.dataStoreURL
        let data = try Data(contentsOf: url)
        return try decoder.decode(AppData.self, from: data)
    }

    func update(_ transform: (inout AppData) -> Void) {
        var updated = data
        transform(&updated)
        data = updated
        save()
    }

    func save() {
        do {
            try directories.ensureDirectoriesExist()
            let data = try encoder.encode(data)
            try data.write(to: directories.dataStoreURL, options: [.atomic])
        } catch {
            NSLog("Failed to save data: \(error)")
        }
    }
}
