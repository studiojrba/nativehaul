import Foundation

extension Game {
    /// Per-source playtime for this game. HLTB estimates are supplied separately and stay labelled.
    func playtimeBreakdown(hltbEstimateSeconds: Int? = nil) -> PlaytimeBreakdown {
        var totals: [PlaytimeSource: Int] = [:]
        for session in sessions {
            totals[session.source, default: 0] += session.durationSeconds
        }
        if let selfReportedSeconds {
            totals[.selfReported, default: 0] += selfReportedSeconds
        }
        if let hltbEstimateSeconds {
            totals[.hltbEstimate] = hltbEstimateSeconds
        }
        return PlaytimeBreakdown(secondsBySource: totals)
    }
}

extension Game {
    /// Seconds from the single biggest real source (tracked or self-reported), never a sum across sources (ADR 0006,
    /// spec §1.10). HLTB estimates never count. `0` when nothing is recorded.
    var biggestRealPlaytimeSeconds: Int {
        playtimeBreakdown().entries
            .filter { !$0.source.isEstimate }
            .map(\.seconds)
            .max() ?? 0
    }

    /// When the game was last played: its latest recorded session, else its stored last-played date.
    var lastPlayedDate: Date? {
        sessions.map(\.endedAt).max() ?? lastPlayedAt
    }
}
