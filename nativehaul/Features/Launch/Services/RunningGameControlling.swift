import Foundation

/// Controls a running game's app for couch's Resume/Close overlay (spec §3.7, TV plan Q3). Live:
/// ``WorkspaceRunningGameController``; mock: ``RecordingRunningGameController``. It brings the *game* forward on
/// Resume; it never activates nativehaul.
@MainActor
protocol RunningGameControlling: AnyObject {
    /// Brings the game at `appPath` to the front.
    func activate(appAt appPath: String)
    /// Asks the game to quit, like ⌘Q, so it can save.
    func terminate(appAt appPath: String)
    /// Quits the game at once (unsaved progress is lost).
    func forceTerminate(appAt appPath: String)
}
