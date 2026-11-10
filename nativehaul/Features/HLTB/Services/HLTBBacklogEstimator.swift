import Foundation

/// Sums HLTB main-story estimates for backlog games. The result is shown separately from real playtime,
/// labelled "HLTB estimate".
enum HLTBBacklogEstimator {
    /// Total estimate and coverage for the backlog.
    static func backlogEstimate(games: [GameSnapshot], estimate: (UUID) -> HLTBEstimate?) -> HLTBBacklogEstimate {
        let backlog = games.filter { $0.status == .backlog }
        let figures = backlog.compactMap { estimate($0.id)?.seconds(for: .mainStory) }
        return HLTBBacklogEstimate(
            seconds: figures.reduce(0, +),
            coveredGames: figures.count,
            backlogGames: backlog.count
        )
    }
}
