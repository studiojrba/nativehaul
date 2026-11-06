import Foundation

/// Pure rules for folding a duplicate ``Game`` into the entry that survives.
///
/// The survivor keeps its identity, title and every value it already has; the duplicate only fills gaps
/// (tracked bundle path, Steam data, dates, …). Sessions and guides move over, so nothing recorded is lost and
/// playtime sources are never summed. Callers repoint series/collections and delete the duplicate afterwards.
@MainActor
enum GameMerger {
    /// Copies the duplicate's data into `survivor` and moves its sessions and guides.
    static func merge(_ duplicate: Game, into survivor: Game) {
        mergeScalars(from: duplicate, into: survivor)
        for session in duplicate.sessions {
            session.game = survivor
        }
        let survivorGuideURLs = Set(survivor.guides.map(\.url))
        for guide in duplicate.guides where !survivorGuideURLs.contains(guide.url) {
            guide.game = survivor
        }
    }

    /// How much hand-entered or imported information a game carries. The richest entry survives a merge.
    static func richness(of game: Game) -> Int {
        let signals = [
            game.status != .backlog,
            !game.summary.isEmpty,
            game.selfReportedSeconds != nil,
            !game.guides.isEmpty,
            game.hltbID != nil,
            game.releaseDate != nil,
            game.completedAt != nil,
            game.coverImagePath != nil,
        ]
        return signals.count { $0 }
    }

    /// Whether two entries can be the same game: they must not point at two different bundles or Steam apps.
    static func areCompatible(_ lhs: Game, _ rhs: Game) -> Bool {
        let bundlesClash = lhs.appBundlePath.map(BundlePath.normalize) != rhs.appBundlePath.map(BundlePath.normalize)
            && lhs.appBundlePath != nil && rhs.appBundlePath != nil
        let steamClash = lhs.steamAppID != rhs.steamAppID && lhs.steamAppID != nil && rhs.steamAppID != nil
        return !bundlesClash && !steamClash
    }

    private static func mergeScalars(from duplicate: Game, into survivor: Game) {
        if survivor.platform == .other, duplicate.platform != .other {
            survivor.platform = duplicate.platform
        }
        if survivor.status == .backlog, duplicate.status != .backlog {
            survivor.status = duplicate.status
        }
        if survivor.summary.isEmpty {
            survivor.summary = duplicate.summary
        }
        survivor.releaseDate = survivor.releaseDate ?? duplicate.releaseDate
        survivor.addedAt = min(survivor.addedAt, duplicate.addedAt)
        survivor.completedAt = survivor.completedAt ?? duplicate.completedAt
        survivor.lastPlayedAt = [survivor.lastPlayedAt, duplicate.lastPlayedAt].compactMap(\.self).max()
        survivor.coverImagePath = survivor.coverImagePath ?? duplicate.coverImagePath
        survivor.steamAppID = survivor.steamAppID ?? duplicate.steamAppID
        survivor.appBundlePath = survivor.appBundlePath ?? duplicate.appBundlePath
        survivor.steamSyncedSeconds = survivor.steamSyncedSeconds ?? duplicate.steamSyncedSeconds
        survivor.selfReportedSeconds = survivor.selfReportedSeconds ?? duplicate.selfReportedSeconds
        survivor.steamAchievementsUnlocked = survivor.steamAchievementsUnlocked ?? duplicate.steamAchievementsUnlocked
        survivor.steamAchievementsTotal = survivor.steamAchievementsTotal ?? duplicate.steamAchievementsTotal
        survivor.hltbID = survivor.hltbID ?? duplicate.hltbID
    }
}
