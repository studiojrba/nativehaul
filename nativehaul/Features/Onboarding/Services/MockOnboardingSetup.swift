import Foundation

/// Mock ``OnboardingSetupPerforming`` for previews and tests: fixed facts and scan results, and a record of every
/// real effect asked for.
@MainActor
final class MockOnboardingSetup: OnboardingSetupPerforming {
    /// The facts to report.
    var facts: OnboardingFacts
    /// What a scan finds.
    var scanResult: OnboardingScan
    /// What placing the keys file does.
    var keysResult = KeysOutcome.placed
    /// Folders added.
    private(set) var addedFolders: [String] = []
    /// Install locations saved.
    private(set) var installLocations: [String] = []
    /// Keys files placed.
    private(set) var placedKeys: [String] = []
    /// The saved start-up mode.
    private(set) var savedMode: AppMode?
    /// Whether onboarding was marked done.
    private(set) var isCompleted = false
    /// Scans run.
    private(set) var scanCount = 0
    /// The emulator installer.
    let components: any ComponentUpdating
    /// The library key picker's extensions.
    let keysExtensions = ["keys"]

    /// Creates the mock.
    init(
        facts: OnboardingFacts = OnboardingFacts(),
        scanResult: OnboardingScan = .empty,
        components: any ComponentUpdating = MockComponentUpdater()
    ) {
        self.facts = facts
        self.scanResult = scanResult
        self.components = components
    }

    func loadFacts() async -> OnboardingFacts {
        facts
    }

    func addFolderAndScan(_ path: String) async -> OnboardingScan {
        addedFolders.append(path)
        scanCount += 1
        return scanResult
    }

    func scanConfiguredFolders() async -> OnboardingScan {
        scanCount += 1
        return scanResult
    }

    func setInstallLocation(_ path: String) {
        installLocations.append(path)
    }

    func provideKeys(at path: String) -> KeysOutcome {
        placedKeys.append(path)
        return keysResult
    }

    func setDefaultMode(_ mode: AppMode) {
        savedMode = mode
    }

    func markCompleted() {
        isCompleted = true
    }
}
