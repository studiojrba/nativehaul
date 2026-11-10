import Foundation

/// Pure rules for folding a duplicate ``Game`` into the entry that survives.
///
/// The survivor keeps its identity, title and every value it already has; the duplicate only fills gaps
/// (tracked bundle path, ROM, dates, …). Sessions and guides move over, so nothing recorded is lost and
/// playtime sources are never summed. Callers repoint series/collections and delete the duplicate afterwards.
@MainActor
enum GameMerger {
    /// Copies the duplicate's data into `survivor` and moves its sessions and guides.
    static func merge(_ duplicate: Game, into survivor: Game) {
        let gaps = MetadataField.allCases.filter { survivor.isMissing($0) && !duplicate.isMissing($0) }
        mergeScalars(from: duplicate, into: survivor)
        mergeProvenance(from: duplicate, into: survivor, filling: gaps)
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
            game.developer != nil,
            !game.genres.isEmpty,
        ]
        return signals.count { $0 }
    }

    /// Whether two entries can be the same game: they must not point at two different bundles or ROMs.
    static func areCompatible(_ lhs: Game, _ rhs: Game) -> Bool {
        let bundlesClash = lhs.appBundlePath.map(BundlePath.normalize) != rhs.appBundlePath.map(BundlePath.normalize)
            && lhs.appBundlePath != nil && rhs.appBundlePath != nil
        let romClash = lhs.romPath != rhs.romPath && lhs.romPath != nil && rhs.romPath != nil
        return !bundlesClash && !romClash && !romMeetsOtherRoute(lhs, rhs) && !romMeetsOtherRoute(
            rhs,
            lhs
        )
    }

    /// A ROM entry never merges with an app of the same title (a port or remake isn't the original).
    private static func romMeetsOtherRoute(_ rom: Game, _ other: Game) -> Bool {
        rom.romPath != nil && other.appBundlePath != nil
    }

    /// Fields the duplicate filled carry the duplicate's provenance, so manual art stays protected after a merge.
    private static func mergeProvenance(from duplicate: Game, into survivor: Game, filling gaps: [MetadataField]) {
        var provenance = survivor.metadataProvenance
        let duplicateProvenance = duplicate.metadataProvenance
        for field in gaps {
            provenance[field] = duplicateProvenance[field]
        }
        survivor.metadataProvenance = provenance
    }

    /// Order-preserving union, case-insensitive.
    private static func union(_ lhs: [String], _ rhs: [String]) -> [String] {
        var seen = Set<String>()
        return (lhs + rhs).filter { seen.insert($0.lowercased()).inserted }
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
        survivor.appBundlePath = survivor.appBundlePath ?? duplicate.appBundlePath
        survivor.romPath = survivor.romPath ?? duplicate.romPath
        survivor.emulatedSystemRaw = survivor.emulatedSystemRaw ?? duplicate.emulatedSystemRaw
        survivor.selfReportedSeconds = survivor.selfReportedSeconds ?? duplicate.selfReportedSeconds
        survivor.hltbID = survivor.hltbID ?? duplicate.hltbID
        survivor.developer = survivor.developer ?? duplicate.developer
        survivor.heroImagePath = survivor.heroImagePath ?? duplicate.heroImagePath
        if survivor.trailerVideoURL == nil {
            survivor.trailerVideoURL = duplicate.trailerVideoURL
            survivor.trailerPosterPath = duplicate.trailerPosterPath
        }
        if survivor.carouselImagePaths.isEmpty {
            survivor.carouselImagePaths = duplicate.carouselImagePaths
        }
        survivor.installSizeBytes = survivor.installSizeBytes ?? duplicate.installSizeBytes
        survivor.genres = union(survivor.genres, duplicate.genres)
        survivor.tags = union(survivor.tags, duplicate.tags)
    }
}
