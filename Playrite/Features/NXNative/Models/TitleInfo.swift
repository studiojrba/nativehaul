import Foundation

/// Identifying information for the title being built.
struct TitleInfo: Codable, Equatable, Sendable {
    private static let titleIDLength = 16
    private static let retailPrefix = "01"

    /// 16-hex-digit title ID.
    var titleID: String
    /// The real title, used to rename the finished `.app`.
    var name: String
    /// Architecture.
    var architecture: TitleArchitecture

    /// `true` when the title ID is 16 hexadecimal digits.
    var hasValidTitleID: Bool {
        titleID.count == Self.titleIDLength && titleID.allSatisfy(\.isHexDigit)
    }

    /// `true` when the title ID does not follow the retail `01…` pattern (e.g. homebrew or dev builds).
    var isNonRetailTitleID: Bool {
        hasValidTitleID && !titleID.hasPrefix(Self.retailPrefix)
    }
}
