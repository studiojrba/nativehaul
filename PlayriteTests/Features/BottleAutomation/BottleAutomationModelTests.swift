import Foundation
@testable import Playrite
import Testing

@MainActor
struct BottleAutomationModelTests {
    private let database = BundledRecipeDatabase.load()

    private func steamGame(appID: Int = 1_091_500) -> Game {
        let game = Game(title: "Game", platform: .steam)
        game.steamAppID = appID
        return game
    }

    @Test func bundledDatabaseLoadsWithSeedsAndADefault() {
        #expect(database.schemaVersion == RecipeDatabase.supportedSchemaVersion)
        #expect(database.databaseVersion != "fallback")
        #expect(database.recipes.count >= 5)
        #expect(database.recipe(forSteamAppID: 1_091_500).isDefault == false)
        #expect(database.recipe(forSteamAppID: 1).isDefault)
        #expect(Set(database.recipes.compactMap(\.steamAppID)).count == database.recipes.count)
    }

    @Test func newerDatabaseFormatsAreRefused() {
        let json = #"{"schemaVersion": 99, "databaseVersion": "x", "defaultRecipe": null, "recipes": []}"#
        #expect(throws: (any Error).self) { try RecipeDatabase.decode(Data(json.utf8)) }
    }

    @Test func gateHidesTheButtonForInstalledOrNonSteamGames() {
        let installed = steamGame()
        installed.steamInstalls = [.mac]
        let app = steamGame()
        app.appBundlePath = "/Applications/Game.app"
        for game in [installed, app, Game(title: "No Steam")] {
            #expect(BottleInstallGate.evaluate(
                game, toolchain: FixedCrossOverDetector.installed.toolchain, recipes: database,
                availableBytes: nil, golden: .ready(bottleName: "g")
            ) == .notApplicable)
        }
    }

    @Test func gateShowsTheVerdictEvenWithoutCrossOver() {
        let result = BottleInstallGate.evaluate(
            steamGame(appID: 359_550), toolchain: nil, recipes: database, availableBytes: nil, golden: .crossOverMissing
        )
        guard case let .blocked(verdict) = result else {
            Issue.record("Expected blocked")
            return
        }
        #expect(verdict.rating == .antiCheatBlocked)
    }

    @Test func gateOrderIsCrossOverThenSpaceThenGolden() {
        let game = steamGame()
        let toolchain = FixedCrossOverDetector.installed.toolchain
        #expect(BottleInstallGate.evaluate(
            game,
            toolchain: nil,
            recipes: database,
            availableBytes: 0,
            golden: .notSetUp
        )
            == .crossOverMissing)
        let lowSpace = BottleInstallGate.evaluate(
            game, toolchain: toolchain, recipes: database, availableBytes: 1000, golden: .notSetUp
        )
        #expect(lowSpace == .insufficientSpace(required: 72_000_000_000, available: 1000))
        #expect(BottleInstallGate.evaluate(
            game, toolchain: toolchain, recipes: database, availableBytes: nil, golden: .notSetUp
        ) == .needsGoldenBottle(.notSetUp))
        let ready = BottleInstallGate.evaluate(
            game, toolchain: toolchain, recipes: database, availableBytes: nil, golden: .ready(bottleName: "g")
        )
        guard case let .ready(match, required, estimated) = ready else {
            Issue.record("Expected ready")
            return
        }
        #expect(match.recipe.title == "Cyberpunk 2077")
        #expect(required == 72_000_000_000)
        #expect(estimated)
    }

    @Test func knownInstallSizeIsUsedInsteadOfTheEstimate() {
        let game = steamGame(appID: 7)
        game.installSizeBytes = 10_000_000_000
        let result = BottleInstallGate.evaluate(
            game, toolchain: FixedCrossOverDetector.installed.toolchain, recipes: database,
            availableBytes: 13_000_000_000, golden: .ready(bottleName: "g")
        )
        guard case let .ready(match, required, estimated) = result else {
            Issue.record("Expected ready")
            return
        }
        #expect(match.isDefault)
        #expect(required == 12_000_000_000)
        #expect(!estimated)
    }

    @Test func configEditorAddsOrReplacesTheRecipeSettings() {
        let recipe = database.recipe(forSteamAppID: 1_091_500).recipe
        let fresh = BottleConfigEditor.applying(recipe, to: "[Bottle]\n\"Updater\" = \"1\"")
        #expect(fresh.contains("[EnvironmentVariables]\n\"CX_GRAPHICS_BACKEND\" = \"d3dmetal\"\n\"WINEMSYNC\" = \"1\""))
        let existing = "[EnvironmentVariables]\n\"WINEMSYNC\" = \"0\"\n\"KEEP\" = \"x\"\n"
        let updated = BottleConfigEditor.applying(recipe, to: existing)
        #expect(!updated.contains("\"WINEMSYNC\" = \"0\""))
        #expect(updated.contains("\"KEEP\" = \"x\""))
        #expect(updated.components(separatedBy: "[EnvironmentVariables]").count == 2)
    }

    @Test func configEditorRefusesAMissingConfig() {
        #expect(throws: BottleInstallError.bottleConfigMissing) {
            try BottleConfigEditor.apply(
                database.defaultRecipe,
                toConfigAt: "/nope/cxbottle.conf",
                files: InMemoryFileOperations()
            )
        }
    }

    @Test func manifestStatusReadsProgressAndCompletion() {
        let partial =
            AppManifestStatus(manifest: #""StateFlags" "1026" "BytesDownloaded" "50" "BytesToDownload" "200""#)
        #expect(partial?.isInstalled == false)
        #expect(partial?.fraction == 0.25)
        #expect(AppManifestStatus(manifest: BottleTestbed.installedManifest)?.isInstalled == true)
        #expect(AppManifestStatus(manifest: "nothing") == nil)
    }

    @Test func loginUsersReadsOnlyTheMostRecentID() {
        let text = """
        "users" { "76561197960287930" { "AccountName" "a" "MostRecent" "0" }
                  "76561198000000001" { "AccountName" "b" "MostRecent" "1" } }
        """
        #expect(SteamLoginUsers.mostRecentSteamID(in: text) == "76561198000000001")
        #expect(SteamLoginUsers.mostRecentSteamID(in: "") == nil)
    }

    @Test func plannerNamesBottlesSafelyAndUniquely() {
        let files = InMemoryFileOperations()
        files.addDirectory("/bottles/Retriever – Half-Life 2 Episode One")
        let planner = PerGameBottlePlanner(locations: BottleTestbed.locations, files: files)
        #expect(planner.plan(forTitle: "Half-Life 2: Episode/One")
            .bottleName == "Retriever – Half-Life 2 Episode One 2")
        #expect(PerGameBottlePlanner.sanitize("  ") == "Game")
    }

    @Test func detectorNeedsCrossOversToolsToBeExecutable() {
        let files = InMemoryFileOperations()
        let detector = CrossOverDetector(files: files, candidates: ["/Applications/CrossOver.app"])
        #expect(detector.detect() == nil)
        let configuration = CrossOverLaunchConfiguration(crossOverAppPath: "/Applications/CrossOver.app")
        files.addFile(configuration.cxbottleExecutablePath, executable: true)
        files.addFile(configuration.wineExecutablePath, executable: true)
        #expect(detector.detect()?.configuration == configuration)
    }

    @Test func crossOverArgumentsAreArraysNotShellStrings() {
        let configuration = CrossOverLaunchConfiguration.standard
        #expect(configuration.cloneBottleArguments(bottle: "New Game", source: "Retriever Steam")
            == ["--bottle", "New Game", "--clone", "Retriever Steam"])
        #expect(configuration.createBottleArguments(bottle: "B", template: .win11, description: "d")
            == ["--bottle", "B", "--create", "--template", "win11_64", "--description", "d"])
        #expect(configuration.arguments(bottle: "B", steamExe: "C:\\steam.exe", appID: 5)
            == ["--bottle", "B", "--cx-app", "C:\\steam.exe", "-applaunch", "5"])
    }

    @Test func viewModelRunsTheScriptAndReportsTheOutcome() async throws {
        let installer = MockBottleInstaller(availability: .needsGoldenBottle(.notSetUp))
        var changes = 0
        let viewModel = BottleInstallViewModel(game: Game(title: "G"), installer: installer) { changes += 1 }
        #expect(viewModel.isVisible)
        viewModel.setUpSteam()
        try await Task.sleep(for: .milliseconds(10))
        #expect(viewModel.stage == .steamReady)
        #expect(installer.setUpCount == 1)
        viewModel.dismissResult()
        viewModel.download()
        try await Task.sleep(for: .milliseconds(10))
        #expect(viewModel.stage == .installed)
        #expect(changes == 1)
    }
}
