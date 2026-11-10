import Foundation

/// Live ``BottleInstalling``. Per game: clone the golden bottle (so the Steam sign-in carries over), apply the recipe
/// to the clone, ask Steam to install the game, and watch its appmanifest. On success the bottle is recorded on the
/// game the same way the folder scan records it, so Launch routes to the bottle.
///
/// If Steam's session doesn't survive the clone, the install says so once ("Steam needs a sign-in in this bottle"),
/// waits one more period for the user, then stops with the reason. It never loops and never asks for credentials.
/// Nothing is deleted: a failed install leaves its bottle for the user to inspect or remove in CrossOver.
@MainActor
final class BottleInstallService: BottleInstalling {
    /// Waits between polls (injected so tests never sleep).
    typealias Sleeper = @Sendable (Duration) async throws -> Void

    private let golden: GoldenBottleManager
    private let detector: any CrossOverDetecting
    private let recipes: RecipeDatabase
    private let disk: any DiskSpaceProviding
    private let files: any FileOperating
    private let runner: any CommandRunning
    private let planner: any BottlePlanning
    private let client: any StoreClientInstalling
    private let repository: any LibraryRepository
    private let timing: BottleInstallTiming
    private let sleeper: Sleeper
    private let bottlesRoot: String
    private var activePlans: [UUID: BottlePlan] = [:]

    /// Creates the service.
    init(
        golden: GoldenBottleManager,
        detector: any CrossOverDetecting,
        recipes: RecipeDatabase,
        disk: any DiskSpaceProviding,
        files: any FileOperating,
        runner: any CommandRunning,
        planner: any BottlePlanning,
        client: any StoreClientInstalling,
        repository: any LibraryRepository,
        locations: CrossOverLocations = .standard,
        timing: BottleInstallTiming = .live,
        sleeper: @escaping Sleeper = { try await Task.sleep(for: $0) }
    ) {
        self.golden = golden
        self.detector = detector
        self.recipes = recipes
        self.disk = disk
        self.files = files
        self.runner = runner
        self.planner = planner
        self.client = client
        self.repository = repository
        self.timing = timing
        self.sleeper = sleeper
        bottlesRoot = (locations.bottlesRoot as NSString).expandingTildeInPath
    }

    func goldenStatus() -> GoldenBottleStatus {
        golden.status()
    }

    func setUpGoldenBottle(onStage: @escaping @MainActor (BottleInstallStage) -> Void) async {
        await golden.setUp(onStage: onStage)
    }

    func availability(for game: Game) -> InstallAvailability {
        BottleInstallGate.evaluate(
            game,
            toolchain: detector.detect(),
            recipes: recipes,
            availableBytes: try? disk.availableBytes(atPath: bottlesRoot),
            golden: golden.status()
        )
    }

    func install(_ game: Game, onStage: @escaping @MainActor (BottleInstallStage) -> Void) async {
        onStage(.checking)
        do {
            try await run(game, onStage: onStage)
            onStage(.installed)
        } catch is CancellationError {
            onStage(.failed(reason: failureText(BottleInstallError.cancelled, game: game)))
        } catch {
            onStage(.failed(reason: failureText(error, game: game)))
        }
    }

    func openSteam(for game: Game?) {
        guard let toolchain = detector.detect() else { return }
        let plan = game.flatMap { activePlans[$0.id] } ?? golden.readyPlan ?? golden.dedicatedPlan
        try? client.openClient(in: plan, toolchain: toolchain)
    }

    private func run(_ game: Game, onStage: @escaping @MainActor (BottleInstallStage) -> Void) async throws {
        let checked = try preflight(game)
        let (toolchain, recipe, store) = (checked.toolchain, checked.recipe, checked.store)
        guard let source = golden.readyPlan, let steamID = golden.linkedSteamID else {
            throw BottleInstallError.goldenBottleNotReady
        }
        let plan = planner.plan(forTitle: game.title)
        activePlans[game.id] = plan
        let commands = CrossOverCommands(runner: runner, toolchain: toolchain)
        onStage(.cloningBottle(name: plan.bottleName))
        try await commands.cloneBottle(plan, from: source.bottleName)
        onStage(.applyingRecipe)
        if recipe.bottleTemplate != GoldenBottle.template {
            try await commands.setWindowsVersion(plan, to: recipe.bottleTemplate)
        }
        try BottleConfigEditor.apply(recipe, toConfigAt: plan.configPath, files: files)
        onStage(.startingDownload)
        try client.startInstall(store, in: plan, toolchain: toolchain)
        let sessionCarried = client.signedInAccountID(in: plan) == steamID
        try await waitForInstall(store, plan: plan, sessionCarried: sessionCarried, onStage: onStage)
        record(plan, on: game)
    }

    private struct Preflight {
        let toolchain: CrossOverToolchain
        let recipe: GameRecipe
        let store: StoreGameReference
    }

    private func preflight(_ game: Game) throws -> Preflight {
        switch availability(for: game) {
        case let .ready(match, _, _):
            guard let toolchain = detector.detect(), let appID = game.steamAppID else {
                throw BottleInstallError.crossOverMissing
            }
            return Preflight(toolchain: toolchain, recipe: match.recipe, store: .steam(appID: appID))
        case .crossOverMissing, .notApplicable: throw BottleInstallError.crossOverMissing
        case let .blocked(verdict): throw BottleInstallError.blocked(verdict)
        case let .insufficientSpace(required, available):
            throw BottleInstallError.insufficientSpace(required: required, available: available)
        case .needsGoldenBottle: throw BottleInstallError.goldenBottleNotReady
        }
    }

    /// Watches the manifest. If nothing starts — or the session clearly didn't carry over — says once that Steam
    /// needs a sign-in in this bottle, gives the user one more period, then stops.
    private func waitForInstall(
        _ store: StoreGameReference,
        plan: BottlePlan,
        sessionCarried: Bool,
        onStage: @escaping @MainActor (BottleInstallStage) -> Void
    ) async throws {
        var askedForSignIn = !sessionCarried
        if askedForSignIn {
            onStage(.needsSignInInBottle(name: plan.bottleName))
        }
        var idlePolls = 0
        while true {
            if let progress = client.installProgress(store, in: plan) {
                if progress.isInstalled {
                    return
                }
                onStage(.downloading(fraction: progress.fraction))
            } else {
                idlePolls += 1
                if idlePolls > (askedForSignIn ? timing.signInPolls : timing.downloadStartPolls) {
                    guard !askedForSignIn else { throw BottleInstallError.signInNeededInBottle(plan.bottleName) }
                    askedForSignIn = true
                    idlePolls = 0
                    onStage(.needsSignInInBottle(name: plan.bottleName))
                }
            }
            try await sleeper(timing.pollInterval)
        }
    }

    private func record(_ plan: BottlePlan, on game: Game) {
        if !game.steamInstalls.contains(plan.installLocation) {
            game.steamInstalls.append(plan.installLocation)
        }
        try? repository.save()
        activePlans[game.id] = nil
    }

    private func failureText(_ error: any Error, game: Game) -> String {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        guard let plan = activePlans[game.id] else { return message }
        return "\(message) The bottle “\(plan.bottleName)” was kept; remove it in CrossOver if you don't need it."
    }
}
