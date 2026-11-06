import Foundation

/// The platform or source a library entry comes from.
enum GamePlatform: String, Codable, CaseIterable, Identifiable, Sendable {
    case steam
    case macNative
    case switchPort
    case other

    /// Stable identity for SwiftUI lists.
    var id: String {
        rawValue
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .steam: "Steam"
        case .macNative: "Mac"
        case .switchPort: "Switch (native port)"
        case .other: "Other"
        }
    }
}
