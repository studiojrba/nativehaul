import Foundation

/// A concrete way to start a game. Planned by ``LaunchPlanner`` and executed by a ``GameLaunching`` service.
enum LaunchTarget: Equatable, Sendable {
    /// Open a `.app` bundle with NSWorkspace (picked up by the playtime watcher).
    case application(path: String)
    /// Open a `.app` bundle with launch arguments (an emulator with a core and ROM). Always a new instance, so the
    /// arguments reach it even when the app is already open.
    case applicationWithArguments(path: String, arguments: [String])

    /// The `.app` this target opens (used by the launch handoff, ADR 0030).
    var appPath: String? {
        switch self {
        case let .application(path), let .applicationWithArguments(path, _): path
        }
    }
}
