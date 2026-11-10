import Foundation
@testable import nativehaul
import Testing

@MainActor
struct StandardFoldersTests {
    private func importer(configured: [String], exists: Bool) throws -> GameFolderImporter {
        try GameFolderImporter(
            folders: InMemoryGameFolderStore(configured),
            discoverer: GameFolderDiscoverer(scanner: MockAppBundleScanner()),
            repository: MockLibraryRepository(),
            trackingPreferences: InMemoryTrackingPreferencesStore()
        ) { _ in exists }
    }

    @Test func skippersStillGetTheStandardSwitchFolderScanned() throws {
        let folders = try importer(configured: [], exists: true).foldersToScan()
        #expect(folders == [TrackingPreferences().expandedGamesFolder])
    }

    @Test func theStandardFolderIsNotAddedTwiceOrWhenMissing() throws {
        #expect(try importer(configured: ["~/Switch/Games"], exists: true).foldersToScan() == ["~/Switch/Games"])
        #expect(try importer(configured: [], exists: false).foldersToScan().isEmpty)
    }
}
