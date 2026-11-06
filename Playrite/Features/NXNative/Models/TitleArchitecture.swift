import Foundation

/// CPU architecture of a title. 32-bit titles are refused.
enum TitleArchitecture: String, Codable, CaseIterable, Sendable, Identifiable {
    case bit64
    case bit32
    case unknown

    /// Identity for pickers.
    var id: String {
        rawValue
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .bit64: "64-bit"
        case .bit32: "32-bit"
        case .unknown: "Unknown"
        }
    }
}
