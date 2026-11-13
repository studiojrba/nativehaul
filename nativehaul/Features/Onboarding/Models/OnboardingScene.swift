import Foundation

/// The preview beside the conversation (spec §3.6 "Scenes").
enum OnboardingScene: String, Sendable {
    /// The logo cluster (page 1).
    case welcome
    /// The games folder and its covers.
    case shelf
    /// The drives.
    case disk
    /// The keys drop zone.
    case keys
    /// The players found.
    case player
    /// The TV.
    case couch

    /// The background wash for the scene.
    var washes: [WashSlot] {
        switch self {
        case .welcome: [.cream, .blush, .sky]
        case .shelf: [.butter, .cream, .mint]
        case .disk: [.sky, .lilac, .butter]
        case .keys: [.blush, .cream, .butter]
        case .player: [.mint, .sky, .cream]
        case .couch: [.cream, .sky, .blush]
        }
    }
}
