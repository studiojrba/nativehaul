import Foundation

/// Runs command-line tools (codesign, xattr, …). Live: ``ProcessCommandRunner``; mock: ``RecordingCommandRunner``.
protocol CommandRunning: Sendable {
    /// Runs a tool to completion and returns its exit status and output.
    func run(executable: String, arguments: [String]) async throws -> CommandResult
}
