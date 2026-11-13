import Foundation

/// A port's build status on Detail (spec §3.3 specs table and build link), from real state only: a build job running
/// for its title, a known newer version, or a built app on disk.
enum DetailBuildState: Equatable, Sendable {
    /// Built and on disk.
    case ready
    /// A build for this title is queued or running.
    case building
    /// A newer version than the built one exists.
    case updateAvailable

    /// The specs table's text.
    var label: String {
        switch self {
        case .ready: "Ready to play"
        case .building: "Building now"
        case .updateAvailable: "Update available"
        }
    }

    /// Whether the status dot is the ready green (otherwise the accent).
    var isReady: Bool {
        self == .ready
    }

    /// The link to Builds under the actions, when the build isn't simply ready.
    var linkText: String? {
        switch self {
        case .ready: nil
        case .building: "It’s building right now — peek at the progress"
        case .updateAvailable: "A new version is ready to build — take a look"
        }
    }

    /// The state for `game`, or `nil` when it has no build to speak of (emulated games, Mac games, ports without an
    /// app). `badge` is the Library's real build badge for the game.
    @MainActor
    static func state(for game: Game, badge: LibraryBuildBadge?) -> DetailBuildState? {
        switch badge {
        case .building: return .building
        case .updateReady: return .updateAvailable
        case nil: break
        }
        return game.platform == .switchPort && game.appBundlePath != nil ? .ready : nil
    }
}
