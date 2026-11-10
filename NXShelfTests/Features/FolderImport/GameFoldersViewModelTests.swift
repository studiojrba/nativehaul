import Foundation
@testable import NXShelf
import Testing

@MainActor
struct GameFoldersViewModelTests {
    @Test func addDedupesAndPersists() {
        let store = InMemoryGameFolderStore(["/Applications"])
        let viewModel = GameFoldersViewModel(store: store, importer: MockGameFolderImporter())
        viewModel.add([URL(fileURLWithPath: "/Applications/"), URL(fileURLWithPath: "/Library")])
        #expect(viewModel.folders == ["/Applications", "/Library"])
        #expect(store.load() == ["/Applications", "/Library"])
        viewModel.remove("/Applications")
        #expect(store.load() == ["/Library"])
    }

    @Test func scanRecordsSummaryAndNotifies() async {
        let importer = MockGameFolderImporter()
        var notified = 0
        let viewModel = GameFoldersViewModel(store: InMemoryGameFolderStore(), importer: importer) { notified += 1 }
        await viewModel.scan()
        #expect(viewModel.lastSummary == importer.summary)
        #expect(importer.scanCount == 1)
        #expect(notified == 1)
        #expect(!viewModel.isScanning)
    }

    @Test func userDefaultsStoreRoundTrips() throws {
        let suite = "NXShelfTests.folders.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        UserDefaultsGameFolderStore(defaults: defaults).save(["/a", "/b"])
        #expect(UserDefaultsGameFolderStore(defaults: defaults).load() == ["/a", "/b"])
    }

    @Test func libraryScanReloadsGames() async throws {
        let repository = try MockLibraryRepository()
        let viewModel = LibraryViewModel(
            repository: repository,
            transfer: LibraryTransferService(repository: repository),
            folderImporter: MockGameFolderImporter()
        )
        #expect(viewModel.canScanFolders)
        await viewModel.scanGameFolders()
        #expect(viewModel.folderImportSummary != nil)
    }
}
