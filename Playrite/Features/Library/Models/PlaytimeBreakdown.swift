import Foundation

/// Playtime for one game, kept separated by source. There is deliberately no merged total (ADR 0006).
struct PlaytimeBreakdown: Equatable, Sendable {
    /// Non-zero entries ordered by `PlaytimeSource.allCases`.
    let entries: [PlaytimeEntry]

    /// Builds a breakdown from per-source second counts, dropping empty sources.
    init(secondsBySource: [PlaytimeSource: Int]) {
        entries = PlaytimeSource.allCases.compactMap { source in
            guard let seconds = secondsBySource[source], seconds > 0 else { return nil }
            return PlaytimeEntry(source: source, seconds: seconds)
        }
    }

    /// Seconds recorded for a given source, or `nil` if none.
    func seconds(for source: PlaytimeSource) -> Int? {
        entries.first { $0.source == source }?.seconds
    }

    /// `true` when no source has any playtime.
    var isEmpty: Bool {
        entries.isEmpty
    }
}
