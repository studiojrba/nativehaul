import Foundation
@testable import NXShelf
import Testing

@MainActor
struct BottleInstallServiceTests {
    private func run(_ service: BottleInstallService, _ game: Game) async -> [BottleInstallStage] {
        var stages: [BottleInstallStage] = []
        await service.install(game) { stages.append($0) }
        return stages
    }

    @Test func clonesTheGoldenBottleAppliesTheRecipeAndRecordsTheInstall() async throws {
        let bed = try await BottleTestbed()
        bed.addBottle("NX Shelf Steam", signedInAs: BottleTestbed.steamID)
        bed.goldenStore.bottleName = "NX Shelf Steam"
        let game = try bed.steamGame()
        let stages = await run(bed.makeService(), game)

        #expect(stages.first == .checking)
        #expect(stages.contains(.cloningBottle(name: "NX Shelf – Cyberpunk 2077")))
        #expect(stages.last == .installed)
        let config = try String(
            bytes: bed.files.readData(atPath: "/bottles/NX Shelf – Cyberpunk 2077/cxbottle.conf"),
            encoding: .utf8
        )
        #expect(config?.contains("\"CX_GRAPHICS_BACKEND\" = \"d3dmetal\"") == true)
        #expect(config?.contains("\"WINEMSYNC\" = \"1\"") == true)
        #expect(bed.files.fileExists(atPath: "/bottles/NX Shelf – Cyberpunk 2077/cxbottle.conf.nxshelf-backup"))
        #expect(game.steamInstalls == [.crossOver(
            bottle: "NX Shelf – Cyberpunk 2077",
            steamRoot: BottleTestbed.steamRoot("NX Shelf – Cyberpunk 2077")
        )])
        let launches = bed.runner.recorded.filter { $0.arguments.contains("-applaunch") }
        #expect(launches.map { $0.arguments[1] } == ["NX Shelf – Cyberpunk 2077"])
        #expect(!bed.files
            .fileExists(atPath: BottleTestbed.steamRoot("NX Shelf Steam") + "/steamapps/appmanifest_1091500.acf"))
    }

    @Test func aLeanSignedInBottleIsAdoptedAutomatically() async throws {
        let bed = try await BottleTestbed()
        bed.addBottle("Steam", signedInAs: BottleTestbed.steamID)
        let service = bed.makeService()
        #expect(service.goldenStatus() == .ready(bottleName: "Steam"))
        #expect(bed.goldenStore.bottleName == "Steam")
    }

    @Test func aBottleFullOfGamesOrAnotherAccountIsNotAdopted() async throws {
        let bed = try await BottleTestbed()
        bed.addBottle("Games", signedInAs: BottleTestbed.steamID, games: [10, 20])
        bed.addBottle("Partner", signedInAs: "76561198000000000")
        #expect(bed.makeService().goldenStatus() == .foundButNotLean(bottleName: "Games"))
        #expect(bed.goldenStore.bottleName == nil)
    }

    @Test func goldenStatusNeedsTheInAppSignInAndCrossOver() async throws {
        let bed = try await BottleTestbed()
        #expect(bed.makeService(crossOver: false).goldenStatus() == .crossOverMissing)
        bed.account.saveSteamID(nil)
        #expect(bed.makeService().goldenStatus() == .steamNotLinked)
    }

    @Test func firstRunCreatesTheDedicatedSteamBottleInstallsSteamAndWaitsForTheOneSignIn() async throws {
        let bed = try await BottleTestbed()
        let service = bed.makeService()
        var stages: [BottleInstallStage] = []
        await service.setUpGoldenBottle { stages.append($0) }
        #expect(stages == [
            .checking, .creatingBottle(name: "NX Shelf Steam"), .installingSteam, .waitingForSignIn, .steamReady,
        ])
        #expect(bed.goldenStore.bottleName == "NX Shelf Steam")
        #expect(service.goldenStatus() == .ready(bottleName: "NX Shelf Steam"))
        #expect(await bed.http.requestedURLs.first?.lastPathComponent == "SteamSetup.exe")
    }

    @Test func signInThatNeverHappensTimesOutWithoutLooping() async throws {
        var behaviour = BottleTestbed.Behaviour()
        behaviour.signInOnOpen = false
        let bed = try await BottleTestbed(behaviour: behaviour)
        var stages: [BottleInstallStage] = []
        await bed.makeService().setUpGoldenBottle { stages.append($0) }
        #expect(stages.last == .failed(reason: BottleInstallError.signInTimedOut.errorDescription ?? ""))
        #expect(bed.runner.recorded.filter(\.isDetached).count == 1)
    }

    @Test func lostSessionSaysSoOnceThenStops() async throws {
        var behaviour = BottleTestbed.Behaviour()
        behaviour.cloneKeepsSession = false
        behaviour.manifestOnLaunch = nil
        let bed = try await BottleTestbed(behaviour: behaviour)
        bed.addBottle("NX Shelf Steam", signedInAs: BottleTestbed.steamID)
        bed.goldenStore.bottleName = "NX Shelf Steam"
        let game = try bed.steamGame()
        let stages = await run(bed.makeService(), game)
        #expect(stages.filter { $0 == .needsSignInInBottle(name: "NX Shelf – Cyberpunk 2077") }.count == 1)
        guard case let .failed(reason) = stages.last else {
            Issue.record("Expected a failure")
            return
        }
        #expect(reason.contains("still needs a sign-in"))
        #expect(reason.contains("was kept"))
        #expect(game.steamInstalls.isEmpty)
    }

    @Test func downloadProgressIsReported() async throws {
        var behaviour = BottleTestbed.Behaviour()
        behaviour.manifestOnLaunch = #""AppState" { "StateFlags" "1026" "BytesDownloaded" "25" "BytesToDownload" "100" }"#
        let bed = try await BottleTestbed(behaviour: behaviour)
        bed.addBottle("NX Shelf Steam", signedInAs: BottleTestbed.steamID)
        bed.goldenStore.bottleName = "NX Shelf Steam"
        let files = bed.files
        let manifest = BottleTestbed.steamRoot("NX Shelf – Cyberpunk 2077") + "/steamapps/appmanifest_1091500.acf"
        let service = bed.makeService(polls: 1) { _ in
            try files.writeData(Data(BottleTestbed.installedManifest.utf8), toPath: manifest)
        }
        let stages = try await run(service, bed.steamGame())
        #expect(stages.contains(.downloading(fraction: 0.25)))
        #expect(stages.last == .installed)
    }

    @Test func cloneFailureNamesTheStep() async throws {
        var behaviour = BottleTestbed.Behaviour()
        behaviour.cloneExitCode = 3
        let bed = try await BottleTestbed(behaviour: behaviour)
        bed.addBottle("NX Shelf Steam", signedInAs: BottleTestbed.steamID)
        bed.goldenStore.bottleName = "NX Shelf Steam"
        let stages = try await run(bed.makeService(), bed.steamGame())
        guard case let .failed(reason) = stages.last else {
            Issue.record("Expected a failure")
            return
        }
        #expect(reason.contains("copy your signed-in Steam bottle (exit code 3)"))
    }

    @Test func windows11RecipesSetTheVersionAfterCloning() async throws {
        let bed = try await BottleTestbed()
        bed.addBottle("NX Shelf Steam", signedInAs: BottleTestbed.steamID)
        bed.goldenStore.bottleName = "NX Shelf Steam"
        var base = BundledRecipeDatabase.fallback
        let recipe = GameRecipe(
            steamAppID: 42, title: "Eleven", bottleTemplate: .win11, graphicsBackend: .dxvk, syncMode: .esync,
            environment: ["DXVK_ASYNC": "1"], notes: "", verdict: CompatibilityVerdict(rating: .works, reason: "ok"),
            installSizeGB: 1
        )
        base = RecipeDatabase(
            schemaVersion: 1,
            databaseVersion: "t",
            defaultRecipe: base.defaultRecipe,
            recipes: [recipe]
        )
        let stages = try await run(bed.makeService(recipes: base), bed.steamGame("Eleven", appID: 42))
        #expect(stages.last == .installed)
        #expect(bed.runner.recorded.contains { $0.arguments.suffix(2) == ["-v", "win11"] })
        let config = try String(
            bytes: bed.files.readData(atPath: "/bottles/NX Shelf – Eleven/cxbottle.conf"),
            encoding: .utf8
        )
        #expect(config?.contains("\"DXVK_ASYNC\" = \"1\"") == true)
        #expect(config?.contains("\"WINEESYNC\" = \"1\"") == true)
    }

    @Test func blockedGamesNeverTouchCrossOver() async throws {
        let bed = try await BottleTestbed()
        bed.addBottle("NX Shelf Steam", signedInAs: BottleTestbed.steamID)
        let service = bed.makeService()
        let game = try bed.steamGame("PUBG", appID: 578_080)
        guard case let .blocked(verdict) = service.availability(for: game) else {
            Issue.record("Expected blocked")
            return
        }
        #expect(verdict.rating == .antiCheatBlocked)
        _ = await run(service, game)
        #expect(bed.runner.recorded.isEmpty)
    }
}
