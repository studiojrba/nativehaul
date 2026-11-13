import Foundation
import Observation

/// A ``FileRevealing`` for previews and tests: remembers what it was asked to reveal.
@MainActor
@Observable
final class RecordingFileRevealer: FileRevealing {
    /// Paths revealed, in order.
    private(set) var revealedPaths: [String] = []

    /// Creates the recorder.
    init() {}

    func reveal(path: String) {
        revealedPaths.append(path)
    }
}
