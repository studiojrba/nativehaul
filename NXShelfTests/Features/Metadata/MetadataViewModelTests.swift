import Foundation
@testable import NXShelf
import Testing

@MainActor
struct MetadataViewModelTests {
    @Test func libraryFetchStoresTheSummary() async throws {
        let fetcher = MockMetadataFetcher()
        fetcher.summary = MetadataFetchSummary(gamesUpdated: 3, finishedAt: .now)
        let viewModel = try LibraryViewModel(
            repository: MockLibraryRepository(),
            transfer: MockLibraryTransferService(),
            metadataFetcher: fetcher
        )
        #expect(viewModel.canFetchMetadata)
        await viewModel.fetchMissingMetadata()
        #expect(fetcher.fetchMissingCount == 1)
        #expect(viewModel.metadataSummary?.gamesUpdated == 3)
    }

    @Test func choosingArtMarksItAsUserSet() throws {
        let game = Game(title: "Mine")
        let viewModel = try GameDetailViewModel(game: game, repository: MockLibraryRepository())
        viewModel.setCoverImagePath("/Users/jr/cover.png")
        #expect(game.metadataProvenance[.cover] == .user)
        viewModel.setCoverImagePath(nil)
        #expect(game.metadataProvenance[.cover] == nil)
    }

    @Test func refreshReportsAndListsSources() async {
        let game = Game(title: "Portal 2")
        game.metadataProvenance = MetadataProvenance([.cover: .titleDB, .hero: .user])
        let fetcher = MockMetadataFetcher()
        var changes = 0
        let viewModel = GameMetadataViewModel(game: game, fetcher: fetcher) { changes += 1 }
        #expect(viewModel.sourceRows.map(\.source) == [.titleDB, .user])
        await viewModel.refresh()
        #expect(fetcher.refreshedGameIDs == [game.id])
        #expect(changes == 1)
        #expect(viewModel.statusMessage == "Nothing new found.")
    }

    @Test func steamGridDBKeyIsSavedAndRemoved() {
        let store = SteamGridDBKeyStore(secrets: InMemorySecretStore())
        let viewModel = ArtworkSettingsViewModel(store: store)
        viewModel.keyInput = "  abc  "
        viewModel.save()
        #expect(viewModel.hasKey)
        #expect(viewModel.keyInput.isEmpty)
        viewModel.removeKey()
        #expect(!viewModel.hasKey)
    }
}
