import Foundation
@testable import nativehaul
import Testing

/// Settings → Players: real players only, the per-system default, and the engine's switch and override.
@MainActor
struct PlayersSettingsViewModelTests {
    private func router(installed: [String]) -> EmulatorRouter {
        let files = InMemoryFileOperations()
        installed.forEach { files.addDirectory("/Applications/\($0)") }
        return EmulatorRouter(preferences: InMemoryEmulatorPreferences(), files: files, appFolders: ["/Applications"])
    }

    @Test func theDetectorReportsOnlyAppsAndAnEngineThatExist() {
        let files = InMemoryFileOperations()
        files.addDirectory("/Applications/Dolphin.app")
        files.addFile("/home/Switch/nxnative", executable: true)
        let detector = LivePlayerDetector(
            router: EmulatorRouter(
                preferences: InMemoryEmulatorPreferences(),
                files: files,
                appFolders: ["/Applications"]
            ),
            engineConfiguration: InMemoryEngineConfigurationStore(),
            locator: NXNativeLocator(files: files, homeDirectory: "/home"),
            files: files
        ) { _ in "2409" }
        #expect(detector.detectedEmulators().map(\.name) == ["Dolphin"])
        #expect(detector.detectedEmulators().first?.detail == "2409 · /Applications/Dolphin.app")
        #expect(detector.detectedEngine()?.path == "/home/Switch/nxnative")
    }

    @Test func makeDefaultRoutesEverySystemThePlayerRuns() throws {
        let router = router(installed: ["RetroArch.app", "Dolphin.app"])
        let detector = MockPlayerDetector.preview
        let viewModel = PlayersSettingsViewModel(
            detector: detector,
            router: router,
            engineConfiguration: InMemoryEngineConfigurationStore()
        )
        let retroArch = try #require(viewModel.emulators.first { $0.id == EmulatorCatalog.retroArch.id })
        let dolphin = try #require(viewModel.emulators.first { $0.id == EmulatorCatalog.dolphin.id })
        #expect(viewModel.isDefault(retroArch))
        #expect(!viewModel.isDefault(dolphin))
        viewModel.makeDefault(dolphin)
        #expect(viewModel.isDefault(dolphin))
        #expect(!viewModel.isDefault(retroArch))
        #expect(router.profile(for: .gameCube).id == EmulatorCatalog.dolphin.id)
        viewModel.makeDefault(retroArch)
        #expect(router.profile(for: .wii).id == EmulatorCatalog.retroArch.id)
    }

    @Test func theEngineSwitchAndOverrideAreRealSettings() {
        let store = InMemoryEngineConfigurationStore()
        let viewModel = PlayersSettingsViewModel(
            detector: MockPlayerDetector(),
            router: router(installed: []),
            engineConfiguration: store
        )
        #expect(viewModel.isEngineEnabled)
        #expect(viewModel.engineDetail == PlayersSettingsViewModel.engineMissing)
        viewModel.isEngineEnabled = false
        #expect(store.load().isSwitchedOffByUser == true)
        viewModel.chooseEngine(URL(fileURLWithPath: "/opt/nxnative"))
        #expect(viewModel.hasEngineOverride)
        viewModel.useDetectedEngine()
        #expect(!viewModel.hasEngineOverride)
    }
}
