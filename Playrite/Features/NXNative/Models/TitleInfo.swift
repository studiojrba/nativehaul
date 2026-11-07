import Foundation

/// Identifying information for the title being built.
struct TitleInfo: Codable, Equatable, Sendable {
    private static let titleIDLength = 16
    /// Retail title IDs: Switch (`01…`) and Switch 2 (`04…`).
    private static let retailPrefixes = ["01", "04"]

    /// 16-hex-digit title ID.
    var titleID: String
    /// The real title, used to rename the finished `.app`.
    var name: String
    /// Architecture.
    var architecture: TitleArchitecture
    /// Numeric version of the game files being built, when known (drives the Switch update badge).
    var version: Int?

    /// `true` when the title ID is 16 hexadecimal digits.
    var hasValidTitleID: Bool {
        titleID.count == Self.titleIDLength && titleID.allSatisfy(\.isHexDigit)
    }

    /// `true` when the title ID does not follow the retail `01…` pattern (e.g. homebrew or dev builds).
    var isNonRetailTitleID: Bool {
        hasValidTitleID && !Self.retailPrefixes.contains { titleID.hasPrefix($0) }
    }
}
