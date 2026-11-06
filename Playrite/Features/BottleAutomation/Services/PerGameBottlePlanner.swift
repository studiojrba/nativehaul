import Foundation

/// One new bottle per game, named "Retriever – <title>", with a number added if that name is taken.
struct PerGameBottlePlanner: BottlePlanning {
    private static let prefix = "Retriever – "
    private static let maxNameLength = 60
    private static let firstSuffix = 2
    private let bottlesRoot: String
    private let files: any FileOperating

    /// Creates the planner over CrossOver's bottles folder.
    init(locations: CrossOverLocations = .standard, files: any FileOperating) {
        bottlesRoot = (locations.bottlesRoot as NSString).expandingTildeInPath
        self.files = files
    }

    func plan(forTitle title: String) -> BottlePlan {
        let base = Self.prefix + Self.sanitize(title)
        var name = base
        var suffix = Self.firstSuffix
        while files.fileExists(atPath: path(for: name)) {
            name = "\(base) \(suffix)"
            suffix += 1
        }
        return BottlePlan(bottleName: name, bottlePath: path(for: name))
    }

    /// A bottle-safe name: no path separators, colons or control characters, trimmed to a sensible length.
    static func sanitize(_ title: String) -> String {
        let forbidden = CharacterSet(charactersIn: "/\\:").union(.controlCharacters)
        let spaced = String(String.UnicodeScalarView(title.unicodeScalars.map { forbidden.contains($0) ? " " : $0 }))
        let cleaned = spaced.split(whereSeparator: \.isWhitespace).joined(separator: " ")
        let trimmed = String(cleaned.prefix(maxNameLength)).trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? "Game" : trimmed
    }

    private func path(for name: String) -> String {
        (bottlesRoot as NSString).appendingPathComponent(name)
    }
}
