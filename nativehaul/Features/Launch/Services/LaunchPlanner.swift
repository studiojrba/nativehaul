import Foundation

/// Pure rules for how an app-based game (a Switch port or other `.app`) launches: the tracked `.app` itself, so
/// playtime is recorded. Emulated games route through ``EmulatorRouter``. No bundle → unavailable, with the reason.
@MainActor
enum LaunchPlanner {
    /// Launch options for `game`.
    static func availability(
        for game: Game,
        fileExists: (String) -> Bool = { FileManager.default.fileExists(atPath: $0) }
    ) -> LaunchAvailability {
        guard let path = game.appBundlePath else {
            return .unavailable(reason: "No app found for this game yet. Add its folder and nativehaul will find it.")
        }
        guard fileExists(path) else {
            return .unavailable(reason: "The game's app is missing at \(path).")
        }
        return .available([LaunchOption(title: "Play", target: .application(path: path), isTracked: true)])
    }
}
