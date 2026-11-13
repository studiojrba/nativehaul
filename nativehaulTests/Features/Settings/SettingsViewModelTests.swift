import Foundation
@testable import nativehaul
import Testing

/// Settings: Directories (keys detected, Valid only when really there), Couch mode persistence, the footer.
@MainActor
struct SettingsViewModelTests {
    @Test func theKeysFileIsDetectedAndValidOnlyWhenReallyThere() {
        let files = InMemoryFileOperations()
        let locator = NXNativeLocator(files: files, homeDirectory: "/home")
        #expect(KeysFileStatus.detect(configuration: EngineConfiguration(), locator: locator, files: files) == .missing)
        files.addFile("/home/Switch/ProdKeys/prod.keys")
        let empty = KeysFileStatus.detect(configuration: EngineConfiguration(), locator: locator, files: files)
        #expect(empty.path == "/home/Switch/ProdKeys/prod.keys")
        #expect(!empty.isValid)
        files.addFile("/home/Switch/ProdKeys/prod.keys", contents: Data("keys".utf8))
        let found = KeysFileStatus.detect(configuration: EngineConfiguration(), locator: locator, files: files)
        #expect(found.isValid)
        #expect(!found.isOverride)
        var chosen = EngineConfiguration()
        chosen.keysPath = "/elsewhere/prod.keys"
        let override = KeysFileStatus.detect(configuration: chosen, locator: locator, files: files)
        #expect(override.isOverride)
        #expect(!override.isValid)
    }

    @Test func directoriesShowTheRealInstallLocationAndKeys() async {
        let environment = AppEnvironment.preview
        let viewModel = environment.makeDirectoriesSettingsViewModel()
        await viewModel.refresh()
        #expect(viewModel.keys.isValid)
        #expect(viewModel.keys.path == "/Users/demo/Switch/ProdKeys/prod.keys")
        viewModel.chooseInstallLocation(URL(fileURLWithPath: "/Volumes/Fast SSD/Builds"))
        #expect(viewModel.installLocation == "/Volumes/Fast SSD/Builds")
        await viewModel.chooseKeysFile(URL(fileURLWithPath: "/missing/prod.keys"))
        #expect(viewModel.keys.isOverride)
        #expect(!viewModel.keys.isValid)
        await viewModel.useDetectedKeys()
        #expect(viewModel.keys.isValid)
    }

    @Test func couchModeAndRumblePersist() throws {
        let defaults = try #require(UserDefaults(suiteName: "SettingsViewModelTests"))
        defaults.removePersistentDomain(forName: "SettingsViewModelTests")
        let store = UserDefaultsModePreferenceStore(defaults: defaults)
        #expect(store.defaultMode == .desktop)
        #expect(store.isRumbleEnabled)
        let viewModel = CouchSettingsViewModel(store: store)
        viewModel.defaultMode = .couch
        viewModel.isRumbleEnabled = false
        let reloaded = UserDefaultsModePreferenceStore(defaults: defaults)
        #expect(reloaded.defaultMode == .couch)
        #expect(!reloaded.isRumbleEnabled)
    }

    @Test func theFooterShowsTheRealVersionAndIsNotSwitchOnly() {
        let footer = SettingsCopy.footer(version: "0.1.0")
        #expect(footer == "nativehaul 0.1.0 · for Switch ports and emulator classics on your Mac")
        #expect(footer.contains("emulator"))
    }

    @Test func addingAFolderScansItStraightAway() async {
        let importer = MockGameFolderImporter()
        let store = InMemoryGameFolderStore(["/Games"])
        let viewModel = GameFoldersViewModel(store: store, importer: importer)
        await viewModel.addAndScan([URL(fileURLWithPath: "/ROMs")])
        #expect(store.load() == ["/Games", "/ROMs"])
        #expect(importer.scanCount == 1)
        await viewModel.replace("/Games", with: URL(fileURLWithPath: "/Switch"))
        #expect(store.load() == ["/Switch", "/ROMs"])
        #expect(importer.scanCount == 2)
    }

    @Test func storedKeysAreReadOffTheMainThreadAndNeverPrefilled() async {
        let viewModel = ArtworkSettingsViewModel(store: MockSteamGridDBKeyStore(hasKey: true))
        #expect(!viewModel.hasKey)
        await viewModel.refresh()
        #expect(viewModel.hasKey)
        #expect(viewModel.keyInput.isEmpty)
        #expect(!viewModel.canSave)
    }
}
