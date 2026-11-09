import Foundation

/// The retroactive cleanup of MacTracked sessions booked before the tracker fix (ADR 0034, J.R ruling 2026-11-09):
/// the fix's own rules applied to stored rows. Pure; ``TrackedSessionRepair`` applies it.
///
/// - **Launcher half of a pair.** A session that contains another session of the same game is a port's launcher
///   process. Under the fix only the game host's time counts, and the host's session is already stored, so the whole
///   launcher row is excess and comes off the books.
/// - **Overlap.** One game can't be played twice at once: a session that runs into the next one of the same game ends
///   where the next one starts.
/// - **Cap.** A session still longer than the cap ends at the cap and is flagged.
struct StaleSessionPlan: Equatable, Sendable {
    /// One stored MacTracked session, reduced to values.
    struct Record: Equatable, Sendable {
        /// The session's ID.
        let id: UUID
        /// The game's ID.
        let gameID: UUID
        /// Stored start.
        let startedAt: Date
        /// Stored end.
        let endedAt: Date
    }

    /// A session whose end moves earlier.
    struct Trim: Equatable, Sendable {
        /// The session as stored.
        let original: Record
        /// The new end.
        let newEnd: Date
        /// `true` when the cap set the end (the session is flagged).
        let isCapped: Bool
    }

    /// Launcher halves to remove.
    let removals: [Record]
    /// Sessions to shorten.
    let trims: [Trim]

    /// `true` when nothing needs changing.
    var isEmpty: Bool {
        removals.isEmpty && trims.isEmpty
    }

    /// Plans the cleanup for `records` (MacTracked only) with the tracker's cap.
    static func make(
        for records: [Record],
        maximumSessionSeconds: Int = SessionTracker.maximumSessionSeconds
    ) -> StaleSessionPlan {
        var removals: [Record] = []
        var trims: [Trim] = []
        for sessions in Dictionary(grouping: records, by: \.gameID).values {
            let launchers = sessions.filter { candidate in sessions.contains { contains(candidate, $0) } }
            removals += launchers
            let kept = sessions.filter { !launchers.contains($0) }.sorted { $0.startedAt < $1.startedAt }
            trims += plannedTrims(kept, limit: TimeInterval(maximumSessionSeconds))
        }
        return StaleSessionPlan(
            removals: removals.sorted { $0.startedAt < $1.startedAt },
            trims: trims.sorted { $0.original.startedAt < $1.original.startedAt }
        )
    }

    /// `outer` holds all of `inner` and is not the same session.
    private static func contains(_ outer: Record, _ inner: Record) -> Bool {
        outer.id != inner.id && outer.startedAt <= inner.startedAt && inner.endedAt <= outer.endedAt
            && (outer.startedAt < inner.startedAt || inner.endedAt < outer.endedAt)
    }

    private static func plannedTrims(_ kept: [Record], limit: TimeInterval) -> [Trim] {
        kept.enumerated().compactMap { index, session in
            let nextStart = index + 1 < kept.count ? kept[index + 1].startedAt : nil
            let capEnd = session.startedAt.addingTimeInterval(limit)
            let end = [session.endedAt, nextStart, capEnd].compactMap(\.self).min() ?? session.endedAt
            guard end < session.endedAt else { return nil }
            return Trim(original: session, newEnd: end, isCapped: end == capEnd && end != nextStart)
        }
    }
}
