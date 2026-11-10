import Foundation
@testable import NXShelf
import Testing

@MainActor
struct GameUpdateBadgeTests {
    private let roots = SteamInstallRoots(macSteamRoot: "/steam", bottlesRoot: "/bottles")

    private typealias Titles = [String: SwitchTitleVersions.Entry]

    private func provider(_ files: InMemoryFileOperations, titles: Titles = [:]) -> GameUpdateBadgeProvider {
        GameUpdateBadgeProvider(
            files: files,
            switchVersions: SwitchTitleVersions(schemaVersion: 1, datasetVersion: "t", titles: titles),
            roots: roots
        )
    }

    private func steamGame(_ installs: [SteamInstallLocation]) -> Game {
        let game = Game(title: "Portal 2", platform: .steam)
        game.steamAppID = 620
        game.steamInstalls = installs
        return game
    }

    @Test func steamBadgesComeFromTheManifestForMacAndBottleAlike() {
        let files = InMemoryFileOperations()
        files.addFile("/steam/steamapps/appmanifest_620.acf", contents: Data(#""StateFlags" "6""#.utf8))
        #expect(provider(files).badge(for: steamGame([.mac])) == .steamUpdatePending)
        let bottle = SteamInstallLocation.crossOver(bottle: "B", steamRoot: "/bottles/B/steam")
        files.addFile("/bottles/B/steam/steamapps/appmanifest_620.acf", contents: Data(
            #""StateFlags" "1048580" "BytesDownloaded" "50" "BytesToDownload" "100""#.utf8
        ))
        #expect(provider(files).badge(for: steamGame([bottle])) == .steamDownloading(fraction: 0.5))
        files.addFile("/steam/steamapps/appmanifest_620.acf", contents: Data(#""StateFlags" "4""#.utf8))
        #expect(provider(files).badge(for: steamGame([.mac])) == nil)
    }

    @Test func switchPortsCompareTheBuiltVersionAndUseJRsCopy() {
        let game = Game(title: "Tideborn", platform: .switchPort)
        game.switchTitleID = "0100abcd00010000"
        game.switchVersion = 65536
        let files = InMemoryFileOperations()
        let titles = ["0100ABCD00010000": SwitchTitleVersions.Entry(latestVersion: 131_072, displayVersion: "1.2.0")]
        let badge = provider(files, titles: titles).badge(for: game)
        #expect(badge == .switchUpdateAvailable(latest: "1.2.0"))
        #expect(badge?.text == "An update is available! Please refer to your original source for update files.")
        game.switchVersion = 131_072
        #expect(provider(files, titles: titles).badge(for: game) == nil)
    }

    @Test func romsNeverHaveABadge() {
        let rom = Game(title: "Fusion", platform: .emulated)
        rom.steamAppID = 1
        #expect(provider(InMemoryFileOperations()).badge(for: rom) == nil)
    }

    @Test func bundledSwitchDatasetLoads() {
        #expect(SwitchTitleVersions.bundled().schemaVersion == SwitchTitleVersions.supportedSchemaVersion)
    }

    @Test func builtPortsRecordTheirTitleIDAndVersion() throws {
        let repository = try MockLibraryRepository()
        let game = try BuiltAppRegistrar(repository: repository, watcher: MockPlaytimeWatcher())
            .register(title: "Tideborn", appPath: "/Games/Tideborn.app", titleID: "0100ABCD00010000", version: 65536)
        #expect(game.switchTitleID == "0100ABCD00010000")
        #expect(game.switchVersion == 65536)
    }
}
