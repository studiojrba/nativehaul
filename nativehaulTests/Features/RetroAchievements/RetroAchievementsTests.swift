import CryptoKit
import Foundation
@testable import nativehaul
import Testing

/// ADR 0047: RetroAchievements by pasted key — RA's ROM hash rules, matching, progress, and silence without keys.
@MainActor
struct RetroAchievementsTests {
    private static let credentials = RetroAchievementsCredentials(username: "jr", apiKey: "ra-key")
    private static let payload = Data("cartridge payload".utf8)

    private static let progressJSON = """
    {"ID": 1446, "Title": "Lantern Coast", "NumAchievements": 2, "NumAwardedToUser": 1,
     "Achievements": {
       "9": {"ID": 9, "Title": "Second", "Description": "Do the second thing", "Points": 10, "BadgeName": "250337",
             "DisplayOrder": 2},
       "8": {"ID": 8, "Title": "First", "Description": "Do the first thing", "Points": 5, "BadgeName": "250336",
             "DisplayOrder": 1, "DateEarned": "2026-11-01 10:00:00"}
     }}
    """

    private func md5(_ data: Data) -> String {
        Insecure.MD5.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func gameListJSON(hash: String) -> String {
        #"[{"ID": 1446, "Title": "Lantern Coast", "Hashes": ["\#(hash)"]}, {"ID": 2, "Title": "Other", "Hashes": []}]"#
    }

    // MARK: Hash rules

    @Test func cartridgeRulesNormaliseLikeRetroAchievements() {
        #expect(RomHashRule.wholeFile.hash(of: Data("abc".utf8)) == "900150983cd24fb0d6963f7d28e17f72")
        let ines = Data([0x4E, 0x45, 0x53, 0x1A] + [UInt8](repeating: 0, count: 12)) + Self.payload
        #expect(RomHashRule.nes.hash(of: ines) == md5(Self.payload))
        #expect(RomHashRule.nes.hash(of: Self.payload) == md5(Self.payload))
        let snesBody = Data(repeating: 7, count: 8192)
        #expect(RomHashRule.snes.hash(of: Data(repeating: 0, count: 512) + snesBody) == md5(snesBody))
        #expect(RomHashRule.snes.hash(of: snesBody) == md5(snesBody))
        let z64 = Data([0x80, 0x37, 0x12, 0x40, 0x01, 0x02, 0x03, 0x04])
        let v64 = Data([0x37, 0x80, 0x40, 0x12, 0x02, 0x01, 0x04, 0x03])
        let n64 = Data([0x40, 0x12, 0x37, 0x80, 0x04, 0x03, 0x02, 0x01])
        #expect(RomHashRule.nintendo64.hash(of: v64) == md5(z64))
        #expect(RomHashRule.nintendo64.hash(of: n64) == md5(z64))
        #expect(RetroAchievementsSystem.identification(for: .playStation2) == nil)
        #expect(RetroAchievementsSystem.identification(for: .gameBoyAdvance)?.consoleID == 5)
    }

    // MARK: Client and service

    private func service(
        _ http: MockHTTPClient,
        credentials: RetroAchievementsCredentials? = credentials,
        rom: Data? = payload
    ) -> RetroAchievementsService {
        let client = RetroAchievementsClient(http: http, credentials: MockRetroAchievementsCredentialStore(credentials))
        return RetroAchievementsService(client: client) { _ in rom }
    }

    @Test func withoutCredentialsItIsSilentlyAbsent() async {
        let http = MockHTTPClient()
        let result = await service(http, credentials: nil).lookup(
            romPath: "/r.gba",
            system: .gameBoyAdvance,
            knownGameID: nil
        )
        #expect(result == .unavailable)
        #expect(await http.requestedURLs.isEmpty)
    }

    @Test func aMatchedROMShowsTheUsersProgressAndTheKeyGoesOnlyToRetroAchievements() async {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "API_GetGameList.php", json: gameListJSON(hash: md5(Self.payload)))
        await http.stub(urlContaining: "API_GetGameInfoAndUserProgress.php", json: Self.progressJSON)
        let ra = service(http)
        let result = await ra.lookup(romPath: "/r.gba", system: .gameBoyAdvance, knownGameID: nil)
        guard case let .found(progress) = result else {
            Issue.record("expected a match, got \(result)")
            return
        }
        #expect(progress.gameID == 1446)
        #expect(progress.earned == 1)
        #expect(progress.achievements.map(\.title) == ["First", "Second"])
        #expect(progress.points == (earned: 5, total: 15))
        #expect(progress.achievements.first?.badgeURL?.lastPathComponent == "250336.png")
        #expect(progress.achievements.last?.badgeURL?.lastPathComponent == "250337_lock.png")
        let urls = await http.requestedURLs
        #expect(urls.allSatisfy { $0.host() == "retroachievements.org" })
        #expect(urls.first?.query()?.contains("i=5") == true)
        #expect(urls.first?.query()?.contains("y=ra-key") == true)
        #expect(urls.last?.query()?.contains("u=jr") == true)
        _ = await ra.lookup(romPath: "/r.gba", system: .gameBoyAdvance, knownGameID: nil)
        #expect(await http.requestedURLs.count { $0.path().hasSuffix("API_GetGameList.php") } == 1)
    }

    @Test func unknownHashesUnsupportedSystemsAndFailuresAreHonest() async {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "API_GetGameList.php", json: gameListJSON(hash: "0000"))
        #expect(await service(http).lookup(romPath: "/r.gba", system: .gameBoyAdvance, knownGameID: nil) == .notFound)
        #expect(await service(http).lookup(romPath: "/r.iso", system: .playStation2, knownGameID: nil)
            == .unsupportedSystem)
        #expect(await service(http, rom: nil).lookup(romPath: "/gone.gba", system: .gameBoyAdvance, knownGameID: nil)
            == .notFound)
        let down = MockHTTPClient()
        await down.stub(urlContaining: "API_GetGameList.php", json: "{}", statusCode: 503)
        #expect(await service(down).lookup(romPath: "/r.gba", system: .gameBoyAdvance, knownGameID: nil) == .failed)
    }

    @Test func aKnownGameIDSkipsHashing() async {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "API_GetGameInfoAndUserProgress.php", json: Self.progressJSON)
        let result = await service(http, rom: nil).lookup(romPath: "/r.gba", system: .gameBoyAdvance, knownGameID: 1446)
        #expect(result != .notFound)
        #expect(await http.requestedURLs.count == 1)
    }

    @Test func keysAreNeverReadOnTheMainThread() async {
        let secrets = ThreadRecordingSecretStore([.retroAchievementsUsername: "jr", .retroAchievementsAPIKey: "k"])
        let http = MockHTTPClient()
        await http.stub(urlContaining: "API_GetGameList.php", json: "[]")
        let client = RetroAchievementsClient(
            http: http,
            credentials: RetroAchievementsCredentialStore(secrets: secrets)
        )
        let rom = Self.payload
        _ = await RetroAchievementsService(client: client) { _ in rom }
            .lookup(romPath: "/r.gba", system: .gameBoyAdvance, knownGameID: nil)
        let settings = RetroAchievementsSettingsViewModel(store: RetroAchievementsCredentialStore(secrets: secrets))
        await settings.refresh()
        #expect(settings.hasCredentials)
        #expect(secrets.backgroundReads >= 1)
        #expect(secrets.mainThreadReads == 0)
    }

    // MARK: View model and settings

    @Test func theSectionRemembersTheMatchAndHidesWithoutKeys() async throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "Lantern Coast", platform: .emulated)
        game.romPath = "/roms/Lantern Coast.gba"
        game.emulatedSystem = .gameBoyAdvance
        repository.insert(game)
        let progress = RetroAchievementsProgress(
            gameID: 1446,
            title: "Lantern Coast",
            total: 0,
            earned: 0,
            achievements: []
        )
        let found = RetroAchievementsViewModel(
            game: game, service: MockRetroAchievementsService(result: .found(progress)), repository: repository
        )
        await found.load()
        #expect(found.isShown)
        #expect(game.retroAchievementsGameID == 1446)
        let silent = RetroAchievementsViewModel(
            game: game,
            service: MockRetroAchievementsService(),
            repository: repository
        )
        await silent.load()
        #expect(!silent.isShown)
    }

    @Test func settingsSaveAndRemove() {
        let store = MockRetroAchievementsCredentialStore()
        let settings = RetroAchievementsSettingsViewModel(store: store)
        settings.usernameInput = "jr"
        #expect(!settings.canSave)
        settings.apiKeyInput = "k"
        settings.save()
        #expect(store.credentials() == RetroAchievementsCredentials(username: "jr", apiKey: "k"))
        #expect(settings.apiKeyInput.isEmpty)
        settings.remove()
        #expect(store.credentials() == nil)
    }
}
