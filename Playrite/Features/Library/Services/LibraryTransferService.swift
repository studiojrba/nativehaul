import Foundation

/// Live ``LibraryTransferring`` implementation.
@MainActor
final class LibraryTransferService: LibraryTransferring {
    private let repository: any LibraryRepository
    private let now: () -> Date

    /// Creates the service. `now` is injectable for deterministic tests.
    init(repository: any LibraryRepository, now: @escaping () -> Date = { .now }) {
        self.repository = repository
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
        let summary = try LibraryArchiveImporter(repository: repository).apply(archive)
        try repository.save()
        return summary
    }
}
