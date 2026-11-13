import Foundation
@testable import nativehaul
import Testing

/// The live onboarding effects over the app's real services (mocked stores): folders through the folder store and the
/// importer, the scan counted from the library, keys placed without overwriting, the mode and completion saved.
@MainActor
struct LiveOnboardingSetupTests {
    private func setup(_ environment: AppEnvironment) -> LiveOnboardingSetup {
        LiveOnboardingSetup(environment: environment, players: MockPlayerDetector.preview) {}
    }

    @Test func addingAFolderSavesItOnceAndCountsOnlyItsGames() async throws {
        let environment = AppEnvironment.preview
        let inside = Game(title: "Lantern Coast", platform: .switchPort)
        inside.appBundlePath = "/Volumes/Games/Lantern Coast.app"
        let outside = Game(title: "Elsewhere", platform: .switchPort)
        outside.appBundlePath = "/Applications/Elsewhere.app"
        environment.repository.insert(inside)
        environment.repository.insert(outside)
        try environment.repository.save()
        let live = setup(environment)
        let scan = await live.addFolderAndScan("/Volumes/Games")
        _ = await live.addFolderAndScan("/Volumes/Games/")
        #expect(environment.gameFolders.load().filter { $0 == "/Volumes/Games" }.count == 1)
        #expect(scan.gameCount == 1)
        #expect(scan.titles == ["Lantern Coast"])
    }

    @Test func factsComeFromTheRealStateWithTheDetectedKeys() async {
        let environment = AppEnvironment.preview
        let facts = await setup(environment).loadFacts()
        #expect(facts.configuredFolders == ["/Users/demo/Switch/Games"])
        #expect(facts.detectedKeys == "/Users/demo/Switch/ProdKeys/prod.keys")
        #expect(facts.players.count == MockPlayerDetector.preview.detectedPlayers().count)
        #expect(facts.installVolume == MockVolumeInspector.preview.startup)
        #expect(facts.externalVolume == nil)
    }

    @Test func installLocationModeAndCompletionAreSaved() {
        let environment = AppEnvironment.preview
        environment.onboarding.hasCompletedOnboarding = false
        let live = setup(environment)
        live.setInstallLocation("/Volumes/Fast SSD/nativehaul")
        live.setDefaultMode(.couch)
        live.markCompleted()
        #expect(environment.engineConfiguration.load().outputDirectory == "/Volumes/Fast SSD/nativehaul")
        #expect(environment.modePreferences.defaultMode == .couch)
        #expect(environment.onboarding.hasCompletedOnboarding)
    }

    @Test func aKeysFileAlreadyInPlaceIsKeptNeverOverwritten() throws {
        let environment = AppEnvironment.preview
        let files = try #require(environment.nxnativeServices.files as? InMemoryFileOperations)
        files.addFile("/tmp/picked.keys", contents: Data("new".utf8))
        #expect(setup(environment).provideKeys(at: "/tmp/picked.keys") == .alreadyThere)
        #expect(try files.readData(atPath: "/Users/demo/Switch/ProdKeys/prod.keys") == Data("preview keys".utf8))
    }

    @Test func theScanPutsRealCoversFirstAndFillsAtMostOneShelf() {
        let games = (0 ..< OnboardingScan.shelfSlots + 2).map { Game(title: "Game \($0)", platform: .switchPort) }
        games.last?.coverImagePath = "/covers/last.png"
        let scan = OnboardingScan.from(games: games)
        #expect(scan.gameCount == games.count)
        #expect(scan.covers.count == OnboardingScan.shelfSlots)
        #expect(scan.covers.first?.imagePath == "/covers/last.png")
    }
}
