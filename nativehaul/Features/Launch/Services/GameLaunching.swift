import Foundation

/// Executes a ``LaunchTarget``. Live: ``WorkspaceGameLauncher``; mock: ``RecordingGameLauncher``.
@MainActor
protocol GameLaunching: AnyObject {
    /// Starts the target with a window preference (ADR 0052). Throws when the system refuses to open it.
    func launch(_ target: LaunchTarget, style: LaunchStyle) async throws
}

extension GameLaunching {
    /// Starts the target the way desktop mode always has (``LaunchStyle/standard``).
    func launch(_ target: LaunchTarget) async throws {
        try await launch(target, style: .standard)
    }
}
