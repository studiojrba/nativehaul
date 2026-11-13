import Foundation
import Observation

/// Settings → Directories (spec §3.5): the game folders (several are supported), where Switch builds are written (the
/// engine's real output folder), and the user's keys file — detected, shown with a **Valid** badge only when the file
/// is
/// really there, and replaceable with the user's own pick. Never hints at where to get it.
@MainActor
@Observable
final class DirectoriesSettingsViewModel {
    /// The game folders and the scan.
    let folders: GameFoldersViewModel
    /// The keys file's real state (read off the main thread by ``refresh()``).
    private(set) var keys = KeysFileStatus.missing

    private let engineConfiguration: any EngineConfigurationStoring
    private let services: NXNativeServices
    private var revision = 0

    /// Creates the view model.
    init(
        folders: GameFoldersViewModel,
        engineConfiguration: any EngineConfigurationStoring,
        services: NXNativeServices
    ) {
        self.folders = folders
        self.engineConfiguration = engineConfiguration
        self.services = services
    }

    /// Where finished Switch builds go (home-abbreviated).
    var installLocation: String {
        _ = revision
        let path = EngineConfiguration.expand(engineConfiguration.load().outputDirectory)
        return (path as NSString).abbreviatingWithTildeInPath
    }

    /// Re-reads the keys file, off the main thread.
    func refresh() async {
        let configuration = engineConfiguration.load()
        let locator = services.locator
        let files = services.files
        keys = await Task
            .detached { KeysFileStatus.detect(configuration: configuration, locator: locator, files: files) }
            .value
    }

    /// Writes Switch builds to the folder the user picked.
    func chooseInstallLocation(_ url: URL) {
        var configuration = engineConfiguration.load()
        configuration.outputDirectory = url.path(percentEncoded: false)
        engineConfiguration.save(configuration)
        revision += 1
    }

    /// Uses the keys file the user picked (an override; the file stays where it is).
    func chooseKeysFile(_ url: URL) async {
        var configuration = engineConfiguration.load()
        configuration.keysPath = url.path(percentEncoded: false)
        engineConfiguration.save(configuration)
        await refresh()
    }

    /// Drops the override so the detected keys file is used.
    func useDetectedKeys() async {
        var configuration = engineConfiguration.load()
        configuration.keysPath = nil
        engineConfiguration.save(configuration)
        await refresh()
    }
}
