import Foundation

/// The platform or source a library entry comes from.
enum GamePlatform: String, Codable, CaseIterable, Identifiable, Sendable {
    case macNative
    case switchPort
    case emulated
    case other

    /// Stable identity for SwiftUI lists.
    var id: String {
        rawValue
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .macNative: "Mac"
        case .switchPort: "Switch (native port)"
        case .emulated: "Emulated"
        case .other: "Other"
        }
    }
}
