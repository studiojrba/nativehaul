import Foundation

/// Outcome of a finished command-line tool run.
struct CommandResult: Equatable, Sendable {
    /// Exit status.
    let exitCode: Int32
    /// Combined standard output and error.
    let output: String

    /// Whether the tool exited with 0.
    var succeeded: Bool {
        exitCode == 0
    }
}
