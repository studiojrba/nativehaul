import Foundation

/// Converts between SwiftData models and ``LibraryArchive`` records.
@MainActor
enum LibraryArchiveMapper {
    /// Builds an archive from live models.
    static func archive(
        games: [Game],
        series: [Series],
        collections: [GameCollection],
        exportedAt: Date
    ) -> LibraryArchive {
        LibraryArchive(
            formatVersion: LibraryArchive.currentFormatVersion,
            exportedAt: exportedAt,
            games: games.map(record(for:)),
            series: series.map(record(for:)),
            collections: collections.map(record(for:))
        )
    }

    static func record(for game: Game) -> GameRecord {
        GameRecord(
            id: game.id, title: game.title, platform: game.platform, status: game.status,
            summary: game.summary, releaseDate: game.releaseDate, addedAt: game.addedAt,
            completedAt: game.completedAt, lastPlayedAt: game.lastPlayedAt,
            coverImagePath: game.coverImagePath, steamAppID: game.steamAppID,
            appBundlePath: game.appBundlePath, steamSyncedSeconds: game.steamSyncedSeconds,
            selfReportedSeconds: game.selfReportedSeconds,
            steamAchievementsUnlocked: game.steamAchievementsUnlocked,
            steamAchievementsTotal: game.steamAchievementsTotal,
            hltbID: game.hltbID,
            developer: game.developer,
            genres: game.genres,
            tags: game.tags,
            heroImagePath: game.heroImagePath,
            carouselImagePaths: game.carouselImagePaths,
            metadataSources: game.metadataSourcesRaw,
            romPath: game.romPath,
            emulatedSystem: game.emulatedSystemRaw,
            sessions: game.sessions.sorted { $0.startedAt < $1.startedAt }.map { session in
                SessionRecord(
                    id: session.id, startedAt: session.startedAt, endedAt: session.endedAt,
                    source: session.source, note: session.note
                )
            },
            guides: game.guides.sorted { $0.addedAt < $1.addedAt }.map { guide in
                GuideRecord(
                    id: guide.id, title: guide.title, author: guide.author, url: guide.url,
                    chapters: guide.chapters, currentChapterID: guide.currentChapterID, addedAt: guide.addedAt
                )
            }
        )
    }

    static func record(for series: Series) -> SeriesRecord {
        SeriesRecord(
            id: series.id, name: series.name, orderBasis: series.orderBasis, notes: series.notes,
            entries: series.orderedEntries.map { entry in
                SeriesEntryRecord(
                    id: entry.id, partLabel: entry.partLabel, position: entry.position,
                    gameID: entry.game?.id, subGameID: entry.subGame?.id
                )
            }
        )
    }

    static func record(for collection: GameCollection) -> CollectionRecord {
        CollectionRecord(
            id: collection.id, name: collection.name, notes: collection.notes,
            parentGameID: collection.parentGame?.id,
            subGames: collection.orderedSubGames.map { subGame in
                SubGameRecord(id: subGame.id, title: subGame.title, position: subGame.position, status: subGame.status)
            }
        )
    }
}
