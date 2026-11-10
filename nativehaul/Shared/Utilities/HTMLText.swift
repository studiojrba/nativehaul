import Foundation

/// Turns store HTML snippets into plain text for descriptions.
enum HTMLText {
    private static let entities: [String: String] = [
        "&amp;": "&", "&quot;": "\"", "&#39;": "'", "&apos;": "'", "&lt;": "<", "&gt;": ">", "&nbsp;": " ",
        "&reg;": "®", "&trade;": "™", "&copy;": "©", "&mdash;": "—", "&ndash;": "–", "&hellip;": "…",
    ]

    /// Plain text: line breaks kept, tags removed, common entities decoded, whitespace tidied.
    static func plain(_ html: String) -> String {
        var text = html.replacingOccurrences(
            of: "<\\s*(br|/p|/li|/h[1-6])\\s*/?>",
            with: "\n",
            options: [.regularExpression, .caseInsensitive]
        )
        text = text.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        for (entity, replacement) in entities {
            text = text.replacingOccurrences(of: entity, with: replacement)
        }
        let lines = text.components(separatedBy: .newlines).map {
            $0.replacingOccurrences(of: "[ \\t]+", with: " ", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)
        }
        return lines.joined(separator: "\n")
            .replacingOccurrences(of: "\n{3,}", with: "\n\n", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
