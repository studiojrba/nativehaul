import Foundation
@testable import nativehaul
import Testing

@MainActor
struct GameUpdateBadgeTests {
    private typealias Titles = [String: SwitchTitleVersions.Entry]

    private func provider(titles: Titles = [:]) -> GameUpdateBadgeProvider {
        GameUpdateBadgeProvider(
            switchVersions: SwitchTitleVersions(schemaVersion: 1, datasetVersion: "t", titles: titles)
        )
    }

    @Test func switchPortsCompareTheBuiltVersionAndUseJRsCopy() {
        let game = Game(title: "Tideborn", platform: .switchPort)
        game.switchTitleID = "0100abcd00010000"
        game.switchVersion = 65536
        let titles = ["0100ABCD00010000": SwitchTitleVersions.Entry(latestVersion: 131_072, displayVersion: "1.2.0")]
        let badge = provider(titles: titles).badge(for: game)
        #expect(badge == .switchUpdateAvailable(latest: "1.2.0"))
        #expect(badge?.text == "An update is available! Please refer to your original source for update files.")
        game.switchVersion = 131_072
        #expect(provider(titles: titles).badge(for: game) == nil)
    }

    @Test func romsNeverHaveABadge() {
        let rom = Game(title: "Fusion", platform: .emulated)
        rom.switchTitleID = "0100ABCD00010000"
        rom.switchVersion = 1
        let titles = ["0100ABCD00010000": SwitchTitleVersions.Entry(latestVersion: 131_072, displayVersion: "1.2.0")]
        #expect(provider(titles: titles).badge(for: rom) == nil)
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
