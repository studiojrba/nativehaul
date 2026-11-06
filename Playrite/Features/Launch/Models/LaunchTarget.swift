import Foundation

/// A concrete way to start a game. Planned by ``LaunchPlanner`` and executed by a ``GameLaunching`` service.
enum LaunchTarget: Equatable, Sendable {
    /// Open a `.app` bundle with NSWorkspace (picked up by the playtime watcher).
    case application(path: String)
    /// Open a URL such as `steam://rungameid/620` with the host's handler.
    case url(URL)
    /// Run an executable with arguments (e.g. CrossOver's wine starting a bottle's Steam).
    case process(executable: String, arguments: [String])
}
