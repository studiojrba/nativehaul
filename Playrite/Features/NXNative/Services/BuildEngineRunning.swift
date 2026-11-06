import Foundation

/// Runs the external engine and streams its output. Live: ``ProcessBuildEngineRunner``; mock:
/// ``MockBuildEngineRunner``.
protocol BuildEngineRunning: Sendable {
    /// Launches the engine. The stream finishes on exit 0 and throws ``BuildError`` otherwise.
    /// Cancelling the consuming task terminates the process.
    func run(_ invocation: EngineInvocation) -> AsyncThrowingStream<BuildLogLine, Error>
}
