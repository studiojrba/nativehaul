import Foundation

/// Sum of main-story HLTB estimates across backlog games. An estimate, never playtime.
struct HLTBBacklogEstimate: Equatable, Sendable {
    /// Total estimated seconds.
    let seconds: Int
    /// Backlog games that have an estimate.
    let coveredGames: Int
    /// All backlog games.
    let backlogGames: Int
}
