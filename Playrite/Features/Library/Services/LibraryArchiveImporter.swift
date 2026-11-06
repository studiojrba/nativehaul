import Foundation

/// Applies a ``LibraryArchive`` to a repository. Items whose identifier already exists are skipped.
@MainActor
struct LibraryArchiveImporter {
    private let repository: any LibraryRepository

    /// Creates an importer writing into `repository`.
    init(repository: any LibraryRepository) {
        self.repository = repository
    }

    /// Imports the archive and returns what changed. Caller is responsible for saving.
    func apply(_ archive: LibraryArchive) throws -> ImportSummary {
        guard archive.formatVersion <= LibraryArchive.currentFormatVersion else {
            throw LibraryTransferError.unsupportedFormatVersion(archive.formatVersion)
        }
        var summary = ImportSummary()
        var gamesByID = try Dictionary(uniqueKeysWithValues: repository.fetchGames().map { ($0.id, $0) })
        for record in archive.games {
            guard gamesByID[record.id] == nil else {
                summary.gamesSkipped += 1
                continue
            }
            gamesByID[record.id] = insertGame(record)
            summary.gamesAdded += 1
        }
        let existingCollections = try Set(repository.fetchCollections().map(\.id))
        var subGamesByID: [UUID: SubGame] = [:]
        for record in archive.collections where !existingCollections.contains(record.id) {
            let collection = GameCollection(id: record.id, name: record.name, notes: record.notes)
            repository.insert(collection)
            collection.parentGame = record.parentGameID.flatMap { gamesByID[$0] }
            for subRecord in record.subGames {
                let subGame = SubGame(
                    id: subRecord.id, title: subRecord.title, position: subRecord.position, status: subRecord.status
                )
                repository.insert(subGame)
                subGame.collection = collection
                subGamesByID[subGame.id] = subGame
            }
            summary.collectionsAdded += 1
        }
        let existingSeries = try Set(repository.fetchSeries().map(\.id))
        for record in archive.series where !existingSeries.contains(record.id) {
            insertSeries(record, gamesByID: gamesByID, subGamesByID: subGamesByID)
            summary.seriesAdded += 1
        }
        return summary
    }

    private func insertGame(_ record: GameRecord) -> Game {
        let game = Game(
            id: record.id, title: record.title, platform: record.platform, status: record.status,
            summary: record.summary, releaseDate: record.releaseDate, addedAt: record.addedAt
        )
        game.completedAt = record.completedAt
        game.lastPlayedAt = record.lastPlayedAt
        game.coverImagePath = record.coverImagePath
        game.steamAppID = record.steamAppID
        game.appBundlePath = record.appBundlePath
        game.steamSyncedSeconds = record.steamSyncedSeconds
        game.selfReportedSeconds = record.selfReportedSeconds
        game.steamAchievementsUnlocked = record.steamAchievementsUnlocked
        game.steamAchievementsTotal = record.steamAchievementsTotal
        repository.insert(game)
        for sessionRecord in record.sessions {
            let session = PlaySession(
                id: sessionRecord.id, startedAt: sessionRecord.startedAt, endedAt: sessionRecord.endedAt,
                source: sessionRecord.source, note: sessionRecord.note
            )
            repository.insert(session)
            session.game = game
        }
        return game
    }

    private func insertSeries(_ record: SeriesRecord, gamesByID: [UUID: Game], subGamesByID: [UUID: SubGame]) {
        let series = Series(id: record.id, name: record.name, orderBasis: record.orderBasis, notes: record.notes)
        repository.insert(series)
        for entryRecord in record.entries {
            let entry = SeriesEntry(
                id: entryRecord.id,
                partLabel: entryRecord.partLabel,
                position: entryRecord.position
            )
            repository.insert(entry)
            entry.game = entryRecord.gameID.flatMap { gamesByID[$0] }
            entry.subGame = entryRecord.subGameID.flatMap { subGamesByID[$0] }
            entry.series = series
        }
    }
}
