import Foundation

/// The detail page's two description slots (ADR 0039): a short lead at the top, and the full text further down only
/// when it says more than the lead.
struct DetailDescription: Equatable, Sendable {
    /// Lead text (item 2), or `nil` when the game has no description.
    let short: String?
    /// Full text (item 6), or `nil` when the lead already is the whole description.
    let full: String?

    /// Splits `summary`. A short source (Steam's short description, IGDB's summary) fits the limit and is the lead as
    /// it is; a long one leads with its opening sentences, cut at a sentence end within the limit.
    init(summary: String, limit: Int = DesignTokens.DetailColumn.shortLimit) {
        let text = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            short = nil
            full = nil
            return
        }
        if text.count <= limit {
            short = text
            full = nil
            return
        }
        let lead = Self.opening(of: text, limit: limit)
        short = lead
        full = text
    }

    /// Whole sentences from the start that fit `limit`, else the first paragraph cut at a word with an ellipsis.
    private static func opening(of text: String, limit: Int) -> String {
        var sentences: [String] = []
        text.enumerateSubstrings(in: text.startIndex..., options: .bySentences) { sentence, _, _, stop in
            guard let sentence else { return }
            let candidate = (sentences + [sentence]).joined()
            if candidate.trimmingCharacters(in: .whitespacesAndNewlines).count > limit {
                stop = true
            } else {
                sentences.append(sentence)
            }
        }
        let joined = sentences.joined().trimmingCharacters(in: .whitespacesAndNewlines)
        if !joined.isEmpty {
            return joined
        }
        let cut = text.prefix(limit)
        let word = cut.lastIndex(of: " ").map { cut[..<$0] } ?? cut
        return word.trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }
}
