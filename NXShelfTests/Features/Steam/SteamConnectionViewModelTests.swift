import Foundation
@testable import NXShelf
import Testing

@MainActor
struct SteamConnectionViewModelTests {
    private struct Harness {
        let account: MockSteamAccountStore
        let sync: StubSteamSync
        let opener: RecordingURLOpener
        let viewModel: SteamConnectionViewModel
    }

    private func harness(configured: Bool = false, http: MockHTTPClient? = nil) -> Harness {
        let account = MockSteamAccountStore(configured: configured)
        let sync = StubSteamSync(account: account)
        let opener = RecordingURLOpener()
        let viewModel = SteamConnectionViewModel(
            account: account,
            signIn: MockSteamSignInService(account: account),
            sync: sync,
            opener: opener,
            http: http
        )
        return Harness(account: account, sync: sync, opener: opener, viewModel: viewModel)
    }

    @Test func walksSignedOutToKeyNeededToReady() async {
        let harness = harness()
        #expect(harness.viewModel.stage == .signedOut)
        await harness.viewModel.signIn()
        #expect(harness.viewModel.stage == .keyNeeded)
        harness.viewModel.keyInput = "  ABC123  "
        await harness.viewModel.saveKey()
        #expect(harness.viewModel.stage == .readyToSync)
        #expect(harness.viewModel.keyInput.isEmpty)
        #expect(harness.viewModel.accountName == "Lantern Keeper")
        #expect(harness.viewModel.notice == nil)
    }

    @Test func rejectedKeyIsNotKeptAndSaysSo() async {
        let harness = harness()
        await harness.viewModel.signIn()
        harness.sync.profileResult = .failure(.invalidAPIKey)
        harness.viewModel.keyInput = "wrong"
        await harness.viewModel.saveKey()
        #expect(harness.viewModel.stage == .keyNeeded)
        #expect(!harness.account.hasAPIKey)
        #expect(harness.viewModel.notice == .keyRejected)
    }

    @Test func privateProfileIsExplainedOnValidation() async {
        let harness = harness()
        harness.sync.profileResult = .success(SteamProfileSummary(
            personaName: "Hidden",
            avatarURL: nil,
            isProfilePublic: false
        ))
        await harness.viewModel.signIn()
        harness.viewModel.keyInput = "key"
        await harness.viewModel.saveKey()
        #expect(harness.viewModel.stage == .readyToSync)
        #expect(harness.viewModel.notice == .privateGameDetails)
    }

    @Test func privateGameDetailsOnSyncAreExplainedAndLinked() async throws {
        let harness = harness(configured: true)
        harness.sync.syncResult = .failure(.profileNotPublic)
        await harness.viewModel.syncNow()
        #expect(harness.viewModel.notice == .privateGameDetails)
        harness.viewModel.openPrivacySettings()
        #expect(try harness.opener.opened == [#require(SteamLinks.privacySettings)])
    }

    @Test func syncNowReportsTheSummary() async {
        let harness = harness(configured: true)
        await harness.viewModel.syncNow()
        #expect(harness.sync.syncCount == 1)
        #expect(harness.viewModel.lastSummary?.added == 2)
    }

    @Test func syncIsImpossibleWithoutAKey() async {
        let harness = harness()
        await harness.viewModel.signIn()
        await harness.viewModel.syncNow()
        #expect(harness.sync.syncCount == 0)
    }

    @Test func keyPageOpensSteamsAPIKeyPage() {
        let harness = harness()
        harness.viewModel.openKeyPage()
        #expect(harness.opener.opened.map(\.absoluteString) == ["https://steamcommunity.com/dev/apikey"])
    }

    @Test func signOutReturnsToSignedOutAndKeepsTheKey() {
        let harness = harness(configured: true)
        harness.viewModel.signOut()
        #expect(harness.viewModel.stage == .signedOut)
        #expect(harness.account.hasAPIKey)
    }

    @Test func manualEntryStillWorks() {
        let harness = harness()
        harness.viewModel.manual.steamIDInput = SteamOpenIDFixtures.steamID
        harness.viewModel.manual.apiKeyInput = "typed-key"
        harness.viewModel.manual.save()
        #expect(harness.viewModel.stage == .readyToSync)
    }

    @Test func avatarIsDownloadedNotHotlinked() async {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "avatars.example", data: Data([0xFF, 0xD8, 0xFF, 0xE0]))
        let harness = harness(http: http)
        let avatar = URL(string: "https://avatars.example/a.jpg")
        harness.sync.profileResult = .success(SteamProfileSummary(
            personaName: "A",
            avatarURL: avatar,
            isProfilePublic: true
        ))
        await harness.viewModel.signIn()
        harness.viewModel.keyInput = "key"
        await harness.viewModel.saveKey()
        #expect(harness.viewModel.avatarData?.isEmpty == false)
    }

    @Test func playerSummaryDecodes() async throws {
        let http = MockHTTPClient()
        await http.stub(pathContaining: "GetPlayerSummaries", json: """
        {"response": {"players": [{"steamid": "76561197960287930", "personaname": "Lantern Keeper",
          "avatarfull": "https://avatars.example/full.jpg", "communityvisibilitystate": 3}]}}
        """)
        let profile = try await SteamWebAPIClient(http: http).playerSummary(credentials: SteamTestFixtures.credentials)
        #expect(profile == SteamProfileSummary(
            personaName: "Lantern Keeper",
            avatarURL: URL(string: "https://avatars.example/full.jpg"),
            isProfilePublic: true
        ))
        #expect(await http.requestedURLs.first?.query()?.contains("steamids=") == true)
    }
}
