import Foundation

/// Watches tracked `.app` bundles and records ``PlaytimeSource/macTracked`` sessions.
/// Live: ``PlaytimeWatcher``; mock: ``MockPlaytimeWatcher``.
@MainActor
protocol PlaytimeWatching: AnyObject {
    /// Whether the watcher is observing launches.
    var isRunning: Bool { get }
    /// Tracked games running right now.
    var activeSessions: [ActiveSession] { get }
    /// Starts observing (no-op when disabled in preferences or already running).
    func start()
    /// Stops observing and records any sessions in progress.
    func stop()
    /// Re-reads which games have tracked bundles.
    func refreshTrackedApps()
    /// Credits the next launch of the app at `path` to `gameID` (an emulator starting one ROM).
    func attributeNextLaunch(ofAppAt path: String, to gameID: UUID)
}
