import Foundation

struct PathSanitizer {
    static func sanitize(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let illegalCharacters = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        let components = trimmed.components(separatedBy: illegalCharacters)
        let cleaned = components.joined(separator: "-")
        let collapsed = cleaned.replacingOccurrences(of: "  +", with: " ", options: .regularExpression)
        return collapsed.isEmpty ? "Untitled" : collapsed
    }
}
