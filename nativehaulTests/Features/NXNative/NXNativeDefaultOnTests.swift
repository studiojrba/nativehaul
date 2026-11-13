import Foundation
@testable import nativehaul
import Testing

/// J.R product correction (ADR 0021): the module ships on, detects what the user already has, and only asks for
/// files that exist nowhere.
@MainActor
struct NXNativeDefaultOnTests {
    private typealias Fix = NXNativeFixtures
    private static let home = "/Users/jr"

    private func viewModel(
        _ files: InMemoryFileOperations,
        store: InMemoryEngineConfigurationStore = InMemoryEngineConfigurationStore()
    ) -> NXNativeViewModel {
        let services = NXNativeServices(
            files: files, disk: FixedDiskSpaceProvider(bytes: .max), runner: MockBuildEngineRunner(),
            audit: InMemoryAuditLog(), knowledgeBase: BundledKnowledgeBase(), backupDirectory: "/backups",
            appBundlePath: "/Applications/nativehaul.app", homeDirectory: Self.home
        )
        return NXNativeViewModel(services: services, store: store) { _, _ in }
    }

    private func locator(_ files: InMemoryFileOperations) -> NXNativeLocator {
        NXNativeLocator(files: files, homeDirectory: Self.home)
    }

    // MARK: On by default

    @Test func freshInstallIsOn() {
        #expect(EngineConfiguration().isEnabled)
        #expect(InMemoryEngineConfigurationStore().load().isEnabled)
    }

    @Test func untouchedInstallSavedWithTheOldOffDefaultMigratesToOn() throws {
        let saved = #"{"isEnabled":false,"enginePath":"","argumentTemplate":"{input} {output}","#
            + #""stagingDirectory":"~/Switch/Staging","workRoot":"~/Switch/Work","outputDirectory":"~/Switch/Games","#
            + #""hiddenLibraryFolderName":".nxnative-lib","spaceMultiplier":3}"#
        let decoded = try JSONDecoder().decode(EngineConfiguration.self, from: Data(saved.utf8))
        #expect(decoded.isEnabled)
        #expect(decoded.isSwitchedOffByUser == nil)
        #expect(decoded.stagingDirectory == "~/Switch/Staging")
    }

    @Test func explicitOffIsRespectedAcrossSaves() throws {
        var configuration = EngineConfiguration()
        configuration.isEnabled = false
        let decoded = try JSONDecoder().decode(
            EngineConfiguration.self,
            from: JSONEncoder().encode(configuration)
        )
        #expect(!decoded.isEnabled)
        let files = InMemoryFileOperations()
        files.addFile("\(Self.home)/Switch/nxnative", executable: true)
        let store = InMemoryEngineConfigurationStore(decoded)
        let model = viewModel(files, store: store)
        #expect(model.readiness == .switchedOff)
        model.turnOn()
        #expect(store.load().isSwitchedOffByUser == nil)
        #expect(model.readiness == .ready(enginePath: "\(Self.home)/Switch/nxnative"))
    }

    @Test func settingsToggleOffIsSaved() {
        let store = InMemoryEngineConfigurationStore()
        let settings = NXNativeSettingsViewModel(store: store, locator: locator(InMemoryFileOperations()))
        settings.configuration.isEnabled = false
        settings.save()
        #expect(store.load().isSwitchedOffByUser == true)
    }

    // MARK: prod.keys detection

    @Test func keysAreSearchedInTheDocumentedOrder() {
        let files = InMemoryFileOperations()
        files.addFile("\(Self.home)/Switch/ProdKeys.NET-v22.5.0/prod.keys")
        files.addFile("\(Self.home)/Switch/ProdKeys.NET-v21.0.0/prod.keys")
        let paths = locator(files).keysSearchPaths
        #expect(paths.prefix(Self.expectedKeysOrder.count) == ArraySlice(Self.expectedKeysOrder))
        #expect(paths.dropFirst(Self.expectedKeysOrder.count).first == "\(Self.home)/.switch/prod.keys")
    }

    @Test(arguments: [
        ["/Switch/ProdKeys/prod.keys", "/Switch/ProdKeys.NET-v22.5.0/prod.keys", "/.switch/prod.keys"],
        ["/Switch/ProdKeys.NET-v22.5.0/prod.keys", "/.switch/prod.keys"],
        ["/.switch/prod.keys", "/Library/Application Support/Ryujinx/system/prod.keys"],
    ])
    func firstExistingKeysWin(present: [String]) {
        let files = InMemoryFileOperations()
        present.forEach { files.addFile(Self.home + $0) }
        #expect(locator(files).detectedKeys() == Self.home + (present.first ?? ""))
    }

    @Test func detectedKeysAreUsedSilently() throws {
        let files = Fix.files()
        files.addFile("\(Self.home)/Switch/ProdKeys/prod.keys")
        var configuration = Fix.configuration
        configuration.keysPath = nil
        let model = viewModel(files, store: InMemoryEngineConfigurationStore(configuration))
        model.enqueue(sourcePath: Fix.source, title: Fix.title)
        let job = try #require(model.jobs.first)
        #expect(!model.needsKeys(job))
        #expect(model.configuration.effectiveKeysPath == "\(Self.home)/Switch/ProdKeys/prod.keys")
    }

    @Test func keysPromptAppearsOnlyWhenNoKeysExistAnywhere() throws {
        let files = Fix.files()
        var configuration = Fix.configuration
        configuration.keysPath = nil
        let model = viewModel(files, store: InMemoryEngineConfigurationStore(configuration))
        model.enqueue(sourcePath: Fix.source, title: Fix.title)
        let job = try #require(model.jobs.first)
        #expect(model.needsKeys(job))
        #expect(job.preflight?.checks.first { $0.kind == .keys }?.message == "Please provide your library key.")
    }

    @Test func keysOverrideBeatsDetection() {
        let files = InMemoryFileOperations()
        files.addFile("\(Self.home)/Switch/ProdKeys/prod.keys")
        var configuration = EngineConfiguration()
        configuration.keysPath = "/elsewhere/prod.keys"
        #expect(locator(files).resolve(configuration).keysPath == "/elsewhere/prod.keys")
    }

    // MARK: Engine detection

    @Test func aStandaloneCheckoutUnderSwitchIsDetected() {
        let files = InMemoryFileOperations()
        let script = "\(Self.home)/Switch/nxnative/scripts/build_ipa_from_nsp.py"
        files.addFile(script)
        #expect(viewModel(files).readiness == .ready(enginePath: script))
    }

    /// ADR 0027: the engine is upstream nxnative. A machine whose only copy is bundled inside another app's folder
    /// (J.R's NX Play copy) has no engine as far as nativehaul is concerned.
    @Test func anotherAppsBundledCopyIsNeverDetected() {
        let files = InMemoryFileOperations()
        files.addFile("\(Self.home)/Library/Application Support/NX Play/nxnative/scripts/build_ipa_from_nsp.py")
        files.addFile("/Applications/Some Builder.app/Contents/Resources/nxnative", executable: true)
        #expect(locator(files).detectedEngine() == nil)
        #expect(viewModel(files).readiness == .engineNotFound)
    }

    @Test func engineSearchIsSwitchFolderThenCheckoutThenHomebrew() {
        let paths = locator(InMemoryFileOperations()).engineSearchPaths
        let switchTools = ["Switch", "Switch/Engine", "Switch/Tools"].flatMap { folder in
            ["nxnative", "nxnative.sh", "nxnative.py"].map { "\(Self.home)/\(folder)/\($0)" }
        }
        let homebrew = ["/opt/homebrew/bin", "/usr/local/bin"].flatMap { folder in
            ["nxnative", "nxnative.sh", "nxnative.py"].map { "\(folder)/\($0)" }
        }
        #expect(paths == switchTools + ["\(Self.home)/Switch/nxnative/scripts/build_ipa_from_nsp.py"] + homebrew)
        #expect(!paths.contains { $0.contains("Application Support") || $0.contains(".app/") })
    }

    @Test func anEngineInTheSwitchFolderComesBeforeHomebrew() {
        let files = InMemoryFileOperations()
        files.addFile("/opt/homebrew/bin/nxnative", executable: true)
        files.addFile("\(Self.home)/Switch/Engine/nxnative", executable: true)
        #expect(locator(files).detectedEngine() == "\(Self.home)/Switch/Engine/nxnative")
        let homebrewOnly = InMemoryFileOperations()
        homebrewOnly.addFile("/opt/homebrew/bin/nxnative", executable: true)
        #expect(locator(homebrewOnly).detectedEngine() == "/opt/homebrew/bin/nxnative")
    }

    @Test func foldersAndNonExecutableFilesAreNotEngines() {
        let files = InMemoryFileOperations()
        files.addDirectory("\(Self.home)/Switch/nxnative")
        files.addFile("\(Self.home)/bin/nxnative")
        #expect(locator(files).detectedEngine() == nil)
    }

    @Test func settingsEngineIsAnOverrideOnly() {
        let files = InMemoryFileOperations()
        files.addFile("\(Self.home)/Switch/nxnative", executable: true)
        files.addFile("/custom/engine", executable: true)
        var configuration = EngineConfiguration()
        configuration.enginePath = "/custom/engine"
        #expect(locator(files).resolve(configuration).enginePath == "/custom/engine")
        #expect(locator(files).resolve(EngineConfiguration()).enginePath == "\(Self.home)/Switch/nxnative")
        #expect(EngineConfiguration().enginePath.isEmpty)
    }

    // MARK: Engine not found

    @Test func noEngineAnywhereIsAMissingFileStateNotASetupStep() {
        let model = viewModel(InMemoryFileOperations())
        #expect(model.readiness == .engineNotFound)
        #expect(NXNativeReadiness.engineNotFoundTitle == "No nxnative engine found on this Mac")
        #expect(NXNativeReadiness.engineNotFoundMessage
            == "nativehaul looked in ~/Switch and Homebrew. If your engine is somewhere else, choose it.")
        #expect(NXNativeReadiness.chooseEngineTitle == "Choose Engine…")
        let copy = [NXNativeReadiness.engineNotFoundTitle, NXNativeReadiness.engineNotFoundMessage]
        #expect(!copy.contains { $0.contains("Settings") || $0.localizedCaseInsensitiveContains("enable") })
    }

    @Test func choosingAnEngineMakesThePageReadyAndRechecksJobs() {
        let files = Fix.files()
        files.addFile("/picked/nxnative", executable: true)
        var configuration = Fix.configuration
        configuration.enginePath = ""
        let store = InMemoryEngineConfigurationStore(configuration)
        let model = viewModel(files, store: store)
        model.enqueue(sourcePath: Fix.source, title: Fix.title)
        #expect(model.jobs.first?.preflight?.checks.first { $0.kind == .engine }?.outcome == .failed)
        model.chooseEngine(at: "/picked/nxnative")
        #expect(model.readiness == .ready(enginePath: "/picked/nxnative"))
        #expect(store.load().enginePath == "/picked/nxnative")
        #expect(model.jobs.first?.preflight?.checks.first { $0.kind == .engine }?.outcome == .passed)
    }

    private static let expectedKeysOrder = [
        "\(home)/Switch/ProdKeys/prod.keys",
        "\(home)/Switch/ProdKeys.NET-v22.5.0/prod.keys",
        "\(home)/Switch/ProdKeys.NET-v21.0.0/prod.keys",
    ]
}
