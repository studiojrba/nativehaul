import Foundation

/// Minimal reader for Valve's KeyValues text files (`appmanifest_*.acf`, `libraryfolders.vdf`).
///
/// Only flat `"key"  "value"` pairs are read; nesting is ignored, which is all NX Shelf needs.
enum SteamKeyValues {
    /// Every value for `key` (case-insensitive), in file order, with `\\` and `\"` unescaped.
    static func values(forKey key: String, in text: String) -> [String] {
        let escapedKey = NSRegularExpression.escapedPattern(for: key)
        let pattern = "\"\(escapedKey)\"\\s+\"((?:[^\"\\\\]|\\\\.)*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: range).compactMap { match in
            Range(match.range(at: 1), in: text).map { unescape(String(text[$0])) }
        }
    }

    /// First value for `key`, if any.
    static func value(forKey key: String, in text: String) -> String? {
        values(forKey: key, in: text).first
    }

    private static func unescape(_ value: String) -> String {
        value.replacingOccurrences(of: "\\\\", with: "\\").replacingOccurrences(of: "\\\"", with: "\"")
    }
}
