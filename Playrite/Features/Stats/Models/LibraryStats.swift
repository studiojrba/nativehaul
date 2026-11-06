import Foundation

/// Aggregate statistics. Hours are kept per source; there is intentionally no cross-source total.
struct LibraryStats: Equatable, Sendable {
    /// Number of games.
    let totalGames: Int
    /// Games per status.
    let countsByStatus: [GameStatus: Int]
    /// Games per platform.
    let countsByPlatform: [GamePlatform: Int]
    /// Real recorded seconds per source (never includes HLTB estimates).
    let secondsBySource: [PlaytimeSource: Int]
    /// Completed ÷ all games, 0…1 (0 for an empty library).
    let completionFraction: Double

    /// Count for a status (0 when none).
    func count(_ status: GameStatus) -> Int {
        countsByStatus[status] ?? 0
    }
}
