import Foundation

/// Runs CrossOver's command-line tools. Live: ``ProcessCommandRunner``; mock: ``RecordingCommandRunner``.
protocol CommandRunning: Sendable {
    /// Runs a tool to completion and returns its exit status and output.
    func run(executable: String, arguments: [String]) async throws -> CommandResult
    /// Starts a tool and returns immediately (used for Steam's window, which keeps running).
    func start(executable: String, arguments: [String]) throws
}
