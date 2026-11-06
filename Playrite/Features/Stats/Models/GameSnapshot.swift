import Foundation

/// Immutable copy of a game's real recorded data, decoupled from SwiftData for pure computation.
struct GameSnapshot: Equatable, Sendable, Identifiable {
    let id: UUID
    let title: String
    let platform: GamePlatform
    let status: GameStatus
    let steamSyncedSeconds: Int?
    let selfReportedSeconds: Int?
    let sessions: [SessionSnapshot]
    let steamAchievementsUnlocked: Int?
    let steamAchievementsTotal: Int?

    /// Real playtime per source (no HLTB). Sources are never added together.
    var realSecondsBySource: [PlaytimeSource: Int] {
        var totals: [PlaytimeSource: Int] = [:]
        for session in sessions where !session.source.isEstimate {
            totals[session.source, default: 0] += session.durationSeconds
        }
        if let steamSyncedSeconds {
            totals[.steamSynced, default: 0] += steamSyncedSeconds
        }
        if let selfReportedSeconds {
            totals[.selfReported, default: 0] += selfReportedSeconds
        }
        return totals
    }
}
