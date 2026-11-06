import Foundation

/// The Windows version a new bottle is created from.
enum BottleTemplate: String, Codable, Sendable {
    /// Windows 10 (64-bit).
    case win10
    /// Windows 11 (64-bit).
    case win11

    /// The template name `cxbottle --template` expects.
    var cxbottleTemplate: String {
        "\(rawValue)_64"
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .win10: "Windows 10"
        case .win11: "Windows 11"
        }
    }
}
