import Foundation

/// A game's short title (spec §6 `short`): the main title before a subtitle separator ("Oxenfree II: Lost Signals" →
/// "Oxenfree II"). Titles without a subtitle, or whose main part would be too short to stand alone, stay whole.
enum ShortTitle {
    /// Subtitle separators, in the order they are tried.
    static let separators = [": ", " – ", " — ", " - "]
    /// The main part must be at least this long to stand alone.
    static let minimumLength = 3

    /// The short form of `title`.
    static func make(from title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        for separator in separators {
            guard let range = trimmed.range(of: separator) else { continue }
            let main = trimmed[..<range.lowerBound].trimmingCharacters(in: .whitespaces)
            let rest = trimmed[range.upperBound...].trimmingCharacters(in: .whitespaces)
            if main.count >= minimumLength, !rest.isEmpty {
                return main
            }
        }
        return trimmed
    }
}
