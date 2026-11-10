import Foundation

/// A single playtime figure tagged with its source.
struct PlaytimeEntry: Equatable, Hashable, Sendable, Identifiable {
    /// Where the figure came from.
    let source: PlaytimeSource
    /// Duration in seconds.
    let seconds: Int

    /// Identity is the source: a breakdown has at most one entry per source.
    var id: PlaytimeSource {
        source
    }
}
