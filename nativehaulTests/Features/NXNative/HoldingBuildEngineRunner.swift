import Foundation
@testable import nativehaul

/// Test ``BuildEngineRunning`` that streams the given lines and then holds the build open (it never finishes), so a
/// job stays mid-build for layout checks and renders.
struct HoldingBuildEngineRunner: BuildEngineRunning {
    /// Lines streamed before holding.
    var lines: [String]

    func run(_: EngineInvocation) -> AsyncThrowingStream<BuildLogLine, Error> {
        AsyncThrowingStream { continuation in
            for line in lines {
                continuation.yield(BuildLogLine(timestamp: .now, stream: .stdout, text: line))
            }
        }
    }
}
