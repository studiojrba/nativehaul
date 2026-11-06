import Foundation

/// Live ``LibraryTransferring`` implementation.
@MainActor
final class LibraryTransferService: LibraryTransferring {
    private let repository: any LibraryRepository
    private let now: () -> Date
    private let deduplicator: (any LibraryDeduplicating)?

    /// Creates the service. `now` is injectable for deterministic tests; `deduplicator` merges same-titled
    /// entries after every import (J.R's one-game-one-entry rule).
    init(
        repository: any LibraryRepository,
        deduplicator: (any LibraryDeduplicating)? = nil,
        now: @escaping () -> Date = { .now }
    ) {
        self.repository = repository
        self.deduplicator = deduplicator
        self.now = now
    }

    func exportData() throws -> Data {
        let archive = try LibraryArchiveMapper.archive(
            games: repository.fetchGames(),
            series: repository.fetchSeries(),
            collections: repository.fetchCollections(),
            exportedAt: now()
        )
        return try LibraryArchiveCoding.makeEncoder().encode(archive)
    }

    func importData(_ data: Data) throws -> ImportSummary {
        let archive = try LibraryArchiveCoding.makeDecoder().decode(LibraryArchive.self, from: data)
        var summary = try LibraryArchiveImporter(repository: repository).apply(archive)
        try repository.save()
        summary.duplicatesMerged = try deduplicator?.mergeAll() ?? 0
        return summary
    }
}
