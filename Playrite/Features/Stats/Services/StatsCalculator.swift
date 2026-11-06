import Foundation

/// Pure statistics over a ``LibrarySnapshot``.
enum StatsCalculator {
    /// Computes library statistics. HLTB estimates are never included.
    static func stats(for snapshot: LibrarySnapshot) -> LibraryStats {
        let games = snapshot.games
        var byStatus: [GameStatus: Int] = [:]
        var byPlatform: [GamePlatform: Int] = [:]
        var bySource: [PlaytimeSource: Int] = [:]
        for game in games {
            byStatus[game.status, default: 0] += 1
            byPlatform[game.platform, default: 0] += 1
            for (source, seconds) in game.realSecondsBySource {
                bySource[source, default: 0] += seconds
            }
        }
        let completed = byStatus[.completed] ?? 0
        return LibraryStats(
            totalGames: games.count,
            countsByStatus: byStatus,
            countsByPlatform: byPlatform,
            secondsBySource: bySource.filter { !$0.key.isEstimate && $0.value > 0 },
            completionFraction: games.isEmpty ? 0 : Double(completed) / Double(games.count)
        )
    }
}
