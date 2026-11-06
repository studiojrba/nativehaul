import Foundation

/// Records where each Steam game is installed.
///
/// Provenance is recomputed from scratch on every run, so uninstalled copies disappear. Games are matched by Steam
/// app ID, then by normalised title among entries without a Steam app (one game, one entry); installed games not in
/// the library are added as Steam backlog entries.
@MainActor
enum SteamProvenanceApplier {
    /// Applies `installs` to `games`, calling `insert` for new entries.
    static func apply(
        _ installs: [SteamInstalledApp],
        to games: [Game],
        insert: (Game) -> Void
    ) -> SteamProvenanceSummary {
        var summary = SteamProvenanceSummary()
        summary.macInstalls = installs.count { $0.location.kind == .mac }
        summary.crossOverInstalls = installs.count { $0.location.kind == .crossOver }
        for game in games {
            game.steamInstalls = []
        }
        var byAppID = Dictionary(games.compactMap { game in game.steamAppID.map { ($0, game) } }) { first, _ in first }
        var unlinked = games.filter { $0.steamAppID == nil }
        let grouped = Dictionary(grouping: installs, by: \.appID)
        for appID in grouped.keys.sorted() {
            guard let copies = grouped[appID], let first = copies.first else { continue }
            let game: Game
            if let existing = byAppID[appID] {
                game = existing
            } else if let index = unlinked.firstIndex(where: { TitleNormalizer.matches($0.title, first.name) }) {
                game = unlinked.remove(at: index)
                game.steamAppID = appID
                summary.linked += 1
            } else {
                game = Game(title: first.name, platform: .steam, status: .backlog)
                game.steamAppID = appID
                insert(game)
                summary.added += 1
            }
            byAppID[appID] = game
            var seen = Set<SteamInstallLocation>()
            game.steamInstalls = copies.map(\.location).filter { seen.insert($0).inserted }
            if let size = copies.compactMap(\.sizeOnDisk).max() {
                game.installSizeBytes = size
            }
        }
        return summary
    }
}
