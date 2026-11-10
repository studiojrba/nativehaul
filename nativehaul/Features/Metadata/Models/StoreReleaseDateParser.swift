import Foundation

/// Parses the release-date strings stores return ("18 Apr, 2011", "Apr 18, 2011", "2017-03-03T08:00:00.000Z").
/// Vague dates ("Coming soon", "Q3 2026") return `nil` rather than a guess.
enum StoreReleaseDateParser {
    private static let formats = ["d MMM, yyyy", "MMM d, yyyy", "d MMM yyyy", "d MMMM, yyyy", "MMMM d, yyyy"]

    /// A date for `text`, or `nil` when it is not a specific day.
    static func date(from text: String?) -> Date? {
        guard let text = text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return nil }
        if let date = isoDate(text) {
            return date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: text) {
                return date
            }
        }
        return nil
    }

    private static func isoDate(_ text: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: text) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: text)
    }
}
