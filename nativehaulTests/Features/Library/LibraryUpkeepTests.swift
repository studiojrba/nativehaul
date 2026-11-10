import Foundation
@testable import nativehaul
import Testing

@MainActor
struct LibraryUpkeepTests {
    @Test func upkeepScansAndFetchesWithoutAnySetup() async throws {
        let importer = MockGameFolderImporter()
        let fetcher = MockMetadataFetcher()
        let viewModel = try LibraryViewModel(
            repository: MockLibraryRepository(),
            transfer: MockLibraryTransferService(),
            folderImporter: importer,
            metadataFetcher: fetcher
        )
        await viewModel.runAutomaticUpkeep()
        #expect(fetcher.backgroundCount == 1)
        #expect(viewModel.metadataSummary == nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func backgroundMetadataSkipsGamesAlreadyTriedThisSession() async throws {
        let repository = try MockLibraryRepository()
        repository.insert(Game(title: "Unknown", platform: .switchPort))
        try repository.save()
        let titleDB = MockMetadataProvider(source: .titleDB, switchOnly: true)
        let fetcher = MetadataFetcher(
            repository: repository,
            titleDB: titleDB,
            steamGridDB: MockMetadataProvider(source: .steamGridDB),
            downloader: ArtworkDownloader(http: MockHTTPClient(), cache: InMemoryArtworkCache())
        )
        _ = try await fetcher.fetchMissingInBackground()
        _ = try await fetcher.fetchMissingInBackground()
        #expect(titleDB.lookedUpTitles == ["Unknown"])
        _ = try await fetcher.fetchMissing()
        #expect(titleDB.lookedUpTitles == ["Unknown", "Unknown"])
    }
}
