import Foundation

/// Normalises game titles for matching: case- and diacritic-insensitive, ignoring punctuation and symbols.
///
/// `"Pokémon™: Let's Go!"` and `"pokemon lets go"` normalise to the same key.
enum TitleNormalizer {
    /// Matching key for `title` (lowercase letters and digits only).
    static func key(for title: String) -> String {
        let folded = title.folding(options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive], locale: nil)
        return String(String.UnicodeScalarView(folded.unicodeScalars.filter(CharacterSet.alphanumerics.contains)))
            .lowercased()
    }

    /// Whether two titles normalise to the same non-empty key.
    static func matches(_ lhs: String, _ rhs: String) -> Bool {
        let key = key(for: lhs)
        return !key.isEmpty && key == self.key(for: rhs)
    }
}
