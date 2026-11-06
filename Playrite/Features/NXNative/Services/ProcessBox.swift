import Foundation
import Synchronization

/// Holds a `Process` and per-stream line splitters so `@Sendable` callbacks can reach them.
///
/// `@unchecked Sendable` is safe here because the `Process` is only configured before launch and afterwards only
/// `terminate()`/`isRunning` are called, which Foundation documents as thread-safe; all mutable buffers are behind a
/// `Mutex`.
final class ProcessBox: @unchecked Sendable {
    /// The child process.
    let process = Process()
    private let splitters = Mutex<[BuildLogLine.Stream: LineSplitter]>([:])

    /// Splits new bytes for a stream into complete lines.
    func lines(from data: Data, stream: BuildLogLine.Stream) -> [String] {
        splitters.withLock { $0[stream, default: LineSplitter()].append(data) }
    }

    /// Returns any trailing partial line for a stream.
    func flush(_ stream: BuildLogLine.Stream) -> String? {
        splitters.withLock { $0[stream, default: LineSplitter()].flush() }
    }

    /// Terminates the process if it is still running.
    func terminateIfRunning() {
        if process.isRunning {
            process.terminate()
        }
    }
}
