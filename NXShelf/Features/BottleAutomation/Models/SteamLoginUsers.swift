import Foundation

/// Reads which accounts a Steam client remembers, from its `config/loginusers.vdf`.
///
/// Only SteamID64s and the `MostRecent` flag are read. Account names, persona names and any other fields are
/// ignored; NX Shelf never reads or stores Steam credentials.
enum SteamLoginUsers {
    private static let idGroup = 1
    private static let bodyGroup = 2
    private static let blockPattern = #""(7656119\d{10})"\s*\{([^{}]*)\}"#

    /// The SteamID64 marked `MostRecent`, if any.
    static func mostRecentSteamID(in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: blockPattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        for match in regex.matches(in: text, range: range) {
            guard let idRange = Range(match.range(at: idGroup), in: text),
                  let bodyRange = Range(match.range(at: bodyGroup), in: text)
            else { continue }
            if SteamKeyValues.value(forKey: "MostRecent", in: String(text[bodyRange])) == "1" {
                return String(text[idRange])
            }
        }
        return nil
    }
}
