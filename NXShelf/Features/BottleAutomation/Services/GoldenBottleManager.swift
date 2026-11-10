import Foundation

/// Finds, adopts or creates the golden bottle: the one signed-in Steam that every game's bottle is cloned from.
///
/// A bottle whose Steam last signed in with the SteamID linked in NX Shelf, and which has no games, is adopted
/// automatically. Otherwise "NX Shelf Steam" is created on request and the user signs in there once.
@MainActor
final class GoldenBottleManager {
    private let detector: any CrossOverDetecting
    private let account: any SteamAccountStoring
    private let store: any GoldenBottleStoring
    private let locator: GoldenBottleLocator
    private let files: any FileOperating
    private let runner: any CommandRunning
    private let client: any StoreClientInstalling
    private let timing: BottleInstallTiming
    private let sleeper: BottleInstallService.Sleeper

    /// Creates the manager.
    init(
        detector: any CrossOverDetecting,
        account: any SteamAccountStoring,
        store: any GoldenBottleStoring,
        locator: GoldenBottleLocator,
        files: any FileOperating,
        runner: any CommandRunning,
        client: any StoreClientInstalling,
        timing: BottleInstallTiming,
        sleeper: @escaping BottleInstallService.Sleeper
    ) {
        self.detector = detector
        self.account = account
        self.store = store
        self.locator = locator
        self.files = files
        self.runner = runner
        self.client = client
        self.timing = timing
        self.sleeper = sleeper
    }

    /// The SteamID linked in NX Shelf.
    var linkedSteamID: String? {
        account.steamID?.rawValue
    }

    /// Current status. Adopts a lean, signed-in bottle as a side effect.
    func status() -> GoldenBottleStatus {
        guard let steamID = linkedSteamID else { return .steamNotLinked }
        guard detector.detect() != nil else { return .crossOverMissing }
        if let name = store.bottleName, locator.signedInSteamID(in: locator.plan(for: name)) == steamID {
            return .ready(bottleName: name)
        }
        guard let found = locator.findSignedInBottle(for: steamID) else { return .notSetUp }
        guard found.isLean else { return .foundButNotLean(bottleName: found.name) }
        store.bottleName = found.name
        return .ready(bottleName: found.name)
    }

    /// The golden bottle's plan, when ready.
    var readyPlan: BottlePlan? {
        guard case let .ready(name) = status() else { return nil }
        return locator.plan(for: name)
    }

    /// The plan for the dedicated golden bottle.
    var dedicatedPlan: BottlePlan {
        locator.plan(for: GoldenBottle.dedicatedName)
    }

    /// Creates "NX Shelf Steam" (or resumes it), installs Steam, opens it and waits for the user to sign in once.
    func setUp(onStage: @escaping @MainActor (BottleInstallStage) -> Void) async {
        onStage(.checking)
        do {
            guard let steamID = linkedSteamID else { throw BottleInstallError.goldenBottleNotReady }
            guard let toolchain = detector.detect() else { throw BottleInstallError.crossOverMissing }
            let plan = dedicatedPlan
            if !files.isDirectory(atPath: plan.bottlePath) {
                onStage(.creatingBottle(name: plan.bottleName))
                try await CrossOverCommands(runner: runner, toolchain: toolchain)
                    .createBottle(plan, template: GoldenBottle.template)
            }
            onStage(.installingSteam)
            try await client.installClient(in: plan, toolchain: toolchain)
            if client.signedInAccountID(in: plan) != steamID {
                onStage(.waitingForSignIn)
                try client.openClient(in: plan, toolchain: toolchain)
                try await waitForAccount(steamID, in: plan)
            }
            store.bottleName = plan.bottleName
            onStage(.steamReady)
        } catch {
            onStage(.failed(reason: (error as? LocalizedError)?.errorDescription ?? error.localizedDescription))
        }
    }

    /// Polls until the bottle's Steam reports `steamID` as signed in.
    func waitForAccount(_ steamID: String, in plan: BottlePlan) async throws {
        for _ in 0 ..< timing.signInPolls {
            if client.signedInAccountID(in: plan) == steamID {
                return
            }
            try await sleeper(timing.pollInterval)
        }
        guard client.signedInAccountID(in: plan) == steamID else { throw BottleInstallError.signInTimedOut }
    }
}
