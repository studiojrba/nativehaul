import Foundation

/// Pure rules for folding Steam's owned-games list into the library.
///
/// Matches by `steamAppID`. Only the ``PlaytimeSource/steamSynced`` figure is written; other sources are untouched.
@MainActor
enum SteamLibraryMerger {
    private static let secondsPerMinute = 60

    /// Applies `owned` to `existing`, calling `insert` for new games. Returns counts.
    static func merge(
        owned: [SteamOwnedGame],
        into existing: [Game],
        insert: (Game) -> Void,
        now: Date
    ) -> SteamSyncSummary {
        var summary = SteamSyncSummary(finishedAt: now)
        let byAppID = Dictionary(existing.compactMap { game in game.steamAppID.map { ($0, game) } }) { first, _ in
            first
        }
        for ownedGame in owned {
            let seconds = ownedGame.playtimeForever * secondsPerMinute
            let lastPlayed = ownedGame.rtimeLastPlayed
                .flatMap { $0 > 0 ? Date(timeIntervalSince1970: TimeInterval($0)) : nil }
            if let game = byAppID[ownedGame.appid] {
                if game.steamSyncedSeconds != seconds {
                    game.steamSyncedSeconds = seconds
                    summary.updated += 1
                }
                if let lastPlayed, lastPlayed > (game.lastPlayedAt ?? .distantPast) {
                    game.lastPlayedAt = lastPlayed
                }
            } else {
                let game = Game(
                    title: ownedGame.name ?? "Steam App \(ownedGame.appid)",
                    platform: .steam,
                    status: .backlog
                )
                game.steamAppID = ownedGame.appid
                game.steamSyncedSeconds = seconds > 0 ? seconds : nil
                game.lastPlayedAt = lastPlayed
                insert(game)
                summary.added += 1
            }
        }
        return summary
    }
}
