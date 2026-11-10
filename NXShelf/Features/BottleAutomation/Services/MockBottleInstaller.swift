import Foundation

/// Mock ``BottleInstalling`` for previews and view-model tests: fixed answers and scripted runs.
@MainActor
final class MockBottleInstaller: BottleInstalling {
    /// Availability to report.
    var fixedAvailability: InstallAvailability
    /// Golden status to report.
    var fixedGoldenStatus: GoldenBottleStatus
    /// Stages an install walks through.
    var installScript: [BottleInstallStage]
    /// Stages the golden setup walks through.
    var setUpScript: [BottleInstallStage] = [.checking, .installingSteam, .waitingForSignIn, .steamReady]
    /// Number of `openSteam` calls.
    private(set) var openSteamCount = 0
    /// Number of golden setups run.
    private(set) var setUpCount = 0

    /// Creates the mock.
    init(
        availability: InstallAvailability = .crossOverMissing,
        goldenStatus: GoldenBottleStatus = .notSetUp,
        installScript: [BottleInstallStage] = [.checking, .cloningBottle(name: "NX Shelf – Sample"), .installed]
    ) {
        fixedAvailability = availability
        fixedGoldenStatus = goldenStatus
        self.installScript = installScript
    }

    func goldenStatus() -> GoldenBottleStatus {
        fixedGoldenStatus
    }

    func setUpGoldenBottle(onStage: @escaping @MainActor (BottleInstallStage) -> Void) async {
        setUpCount += 1
        setUpScript.forEach(onStage)
    }

    func availability(for _: Game) -> InstallAvailability {
        fixedAvailability
    }

    func install(_: Game, onStage: @escaping @MainActor (BottleInstallStage) -> Void) async {
        installScript.forEach(onStage)
    }

    func openSteam(for _: Game?) {
        openSteamCount += 1
    }
}
