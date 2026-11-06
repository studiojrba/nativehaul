import Foundation

/// Executes a ``LaunchTarget``. Live: ``WorkspaceGameLauncher``; mock: ``RecordingGameLauncher``.
@MainActor
protocol GameLaunching: AnyObject {
    /// Starts the target. Throws when the system refuses to open it.
    func launch(_ target: LaunchTarget) async throws
}
