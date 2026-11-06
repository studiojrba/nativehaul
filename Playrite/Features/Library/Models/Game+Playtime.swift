import Foundation

extension Game {
    /// Per-source playtime for this game. HLTB estimates are supplied separately and stay labelled.
    func playtimeBreakdown(hltbEstimateSeconds: Int? = nil) -> PlaytimeBreakdown {
        var totals: [PlaytimeSource: Int] = [:]
        for session in sessions {
            totals[session.source, default: 0] += session.durationSeconds
        }
        if let steamSyncedSeconds {
            totals[.steamSynced, default: 0] += steamSyncedSeconds
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
