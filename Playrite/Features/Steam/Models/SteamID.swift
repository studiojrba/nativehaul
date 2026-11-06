import Foundation

/// A validated 64-bit Steam account identifier (SteamID64).
struct SteamID: Equatable, Hashable, Sendable, CustomStringConvertible {
    private static let requiredLength = 17
    private static let individualPrefix = "7656119"

    /// The 17-digit decimal string.
    let rawValue: String

    /// Returns `nil` unless `string` is a 17-digit individual-account SteamID64.
    init?(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count == Self.requiredLength,
              trimmed.allSatisfy(\.isASCII),
              trimmed.allSatisfy(\.isNumber),
              trimmed.hasPrefix(Self.individualPrefix)
        else { return nil }
        rawValue = trimmed
    }

    var description: String {
        rawValue
    }
}
