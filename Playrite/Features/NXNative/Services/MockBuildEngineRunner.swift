import Foundation

/// Mock ``BuildEngineRunning`` that emits scripted lines and optionally creates output via a callback.
struct MockBuildEngineRunner: BuildEngineRunning {
    /// Lines to emit on stdout.
    var lines: [String] = ["[engine] extracting", "[engine] translating", "[engine] packaging app"]
    /// Exit status to simulate.
    var exitStatus: Int32 = 0
    /// Called before finishing, e.g. to create files in the work directory.
    var onFinish: @Sendable (EngineInvocation) -> Void = { _ in }

    func run(_ invocation: EngineInvocation) -> AsyncThrowingStream<BuildLogLine, Error> {
        AsyncThrowingStream { continuation in
            for line in lines {
                continuation.yield(BuildLogLine(timestamp: .now, stream: .stdout, text: line))
            }
            onFinish(invocation)
            if exitStatus == 0 {
                continuation.finish()
            } else {
                continuation.finish(throwing: BuildError.engineExited(exitStatus))
            }
        }
    }
}
