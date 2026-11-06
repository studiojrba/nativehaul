import Foundation
@testable import Playrite
import Testing

@MainActor
struct LibraryUpkeepTests {
    @Test func upkeepScansSyncsAndFetchesWithoutAnySetup() async throws {
        let importer = MockGameFolderImporter()
        let fetcher = MockMetadataFetcher()
        let sync = MockSteamSyncService(isConfigured: true)
        let viewModel = try LibraryViewModel(
            repository: MockLibraryRepository(),
            transfer: MockLibraryTransferService(),
            folderImporter: importer,
            metadataFetcher: fetcher,
            steamSync: sync
        )
        await viewModel.runAutomaticUpkeep()
        #expect(fetcher.backgroundCount == 1)
        #expect(viewModel.metadataSummary == nil)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func backgroundMetadataSkipsGamesAlreadyTriedThisSession() async throws {
        let repository = try MockLibraryRepository()
        repository.insert(Game(title: "Unknown", platform: .steam))
        try repository.save()
        let steam = MockMetadataProvider(source: .steamStore)
        let fetcher = MetadataFetcher(
            repository: repository,
            steamStore: steam,
            nintendo: MockMetadataProvider(source: .nintendoStore, switchOnly: true),
            steamGridDB: MockMetadataProvider(source: .steamGridDB),
            downloader: ArtworkDownloader(http: MockHTTPClient(), cache: InMemoryArtworkCache())
        )
        _ = try await fetcher.fetchMissingInBackground()
        _ = try await fetcher.fetchMissingInBackground()
        #expect(steam.lookedUpTitles == ["Unknown"])
        _ = try await fetcher.fetchMissing()
        #expect(steam.lookedUpTitles == ["Unknown", "Unknown"])
    }
}
