import Foundation

/// The preview beside the conversation (spec §3.6 "Scenes").
enum OnboardingScene: String, Sendable {
    /// The logo cluster (page 1).
    case welcome
    /// The games folder and its covers.
    case shelf
    /// The Switch build tutorial.
    case build
    /// The drives.
    case disk
    /// The library key drop zone.
    case keys
    /// The emulators found, and the ones on offer.
    case player
    /// The TV.
    case couch
    /// "Your shelf is ready."
    case closing

    /// The background wash for the scene.
    var washes: [WashSlot] {
        switch self {
        case .welcome: [.cream, .blush, .sky]
        case .shelf: [.butter, .cream, .mint]
        case .build, .disk: [.sky, .lilac, .butter]
        case .keys: [.blush, .cream, .butter]
        case .player: [.mint, .sky, .cream]
        case .couch: [.cream, .sky, .blush]
        case .closing: [.cream, .butter, .blush]
        }
    }
}
