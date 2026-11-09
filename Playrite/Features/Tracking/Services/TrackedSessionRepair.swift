import Foundation

/// Applies ``StaleSessionPlan`` to the library once, at launch, before tracking starts (ADR 0034, J.R ruling
/// 2026-11-09). Every change is written to the audit log with the session's original values, so it can be undone.
/// Only MacTracked sessions, and a game's last-played date that came from a removed or trimmed session, change.
@MainActor
struct TrackedSessionRepair {
    /// UserDefaults key recording that the repair has run.
    static let doneKey = "tracking.staleSessionRepair.v1.done"

    let repository: any LibraryRepository
    let audit: any AuditLogging
    let defaults: UserDefaults

    /// Runs the repair unless it already ran. Returns the plan it applied (empty when skipped or nothing was stale).
    @discardableResult
    func runOnce() -> StaleSessionPlan {
        guard !defaults.bool(forKey: Self.doneKey) else { return StaleSessionPlan(removals: [], trims: []) }
        do {
            let plan = try apply()
            defaults.set(true, forKey: Self.doneKey)
            return plan
        } catch {
            try? audit.record(AuditEntry(action: "tracking.repair.failed", target: nil, details: "\(error)"))
            return StaleSessionPlan(removals: [], trims: [])
        }
    }

    private func apply() throws -> StaleSessionPlan {
        let games = try repository.fetchGames()
        let sessions = games.flatMap { game in game.sessions.filter { $0.source == .macTracked } }
        let records = sessions.compactMap { session in
            session.game.map {
                StaleSessionPlan.Record(
                    id: session.id,
                    gameID: $0.id,
                    startedAt: session.startedAt,
                    endedAt: session.endedAt
                )
            }
        }
        let plan = StaleSessionPlan.make(for: records)
        guard !plan.isEmpty else { return plan }
        let byID = Dictionary(sessions.map { ($0.id, $0) }) { first, _ in first }
        let affected = Set(plan.removals.map(\.gameID) + plan.trims.map(\.original.gameID))
        let staleEnds = Set(plan.removals.map(\.endedAt) + plan.trims.map(\.original.endedAt))
        for removal in plan.removals {
            guard let session = byID[removal.id] else { continue }
            try record("tracking.repair.removeLauncherHalf", session.game, removal, details: "removed")
            session.game = nil
            repository.delete(session)
        }
        for trim in plan.trims {
            guard let session = byID[trim.original.id] else { continue }
            try record("tracking.repair.trim", session.game, trim.original, details: "new end \(trim.newEnd)")
            session.endedAt = trim.newEnd
            if trim.isCapped {
                session.note = CompletedSession.noteForCappedSession
            }
        }
        for game in games where affected.contains(game.id) {
            guard let lastPlayed = game.lastPlayedAt, staleEnds.contains(lastPlayed) else { continue }
            let newLast = game.sessions.map(\.endedAt).max()
            try audit.record(AuditEntry(
                action: "tracking.repair.lastPlayed",
                target: game.title,
                details: "lastPlayedAt \(lastPlayed) → \(newLast.map { "\($0)" } ?? "unchanged")"
            ))
            if let newLast {
                game.lastPlayedAt = newLast
            }
        }
        try repository.save()
        return plan
    }

    private func record(_ action: String, _ game: Game?, _ original: StaleSessionPlan.Record, details: String) throws {
        try audit.record(AuditEntry(
            action: action,
            target: game?.title,
            details: "session \(original.id) MacTracked \(original.startedAt) – \(original.endedAt): \(details)"
        ))
    }
}
