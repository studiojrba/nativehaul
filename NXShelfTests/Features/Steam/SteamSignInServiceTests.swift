import Foundation
@testable import NXShelf
import Testing

@MainActor
struct SteamSignInServiceTests {
    private func service(
        _ result: Result<URL, SteamSignInError>,
        steamReply: String?,
        account: MockSteamAccountStore
    ) async -> (SteamOpenIDSignInService, MockHTTPClient) {
        let http = MockHTTPClient()
        if let steamReply {
            await http.stub(urlContaining: "openid/login", json: steamReply)
        }
        let service = SteamOpenIDSignInService(
            browser: MockSteamBrowserSignIn(result: result),
            verifier: SteamOpenIDVerifier(http: http),
            account: account
        )
        return (service, http)
    }

    @Test func confirmedSignInStoresTheSteamIDOnly() async throws {
        let account = MockSteamAccountStore(configured: false)
        let (service, _) = await service(
            .success(SteamOpenIDFixtures.callback()),
            steamReply: "is_valid:true",
            account: account
        )
        let steamID = try await service.signIn()
        #expect(steamID.rawValue == SteamOpenIDFixtures.steamID)
        #expect(account.steamID == steamID)
        #expect(!account.hasAPIKey)
    }

    @Test func steamRejectionStoresNothing() async {
        let account = MockSteamAccountStore(configured: false)
        let (service, _) = await service(
            .success(SteamOpenIDFixtures.callback()),
            steamReply: "is_valid:false",
            account: account
        )
        await #expect(throws: SteamSignInError.rejectedBySteam) { try await service.signIn() }
        #expect(account.steamID == nil)
    }

    @Test func cancellingMakesNoRequest() async {
        let account = MockSteamAccountStore(configured: false)
        let (service, http) = await service(.failure(.cancelled), steamReply: nil, account: account)
        await #expect(throws: SteamSignInError.cancelled) { try await service.signIn() }
        #expect(await http.requestedURLs.isEmpty)
        #expect(account.steamID == nil)
    }

    @Test func signOutForgetsTheAccount() async {
        let account = MockSteamAccountStore(configured: true)
        let (service, _) = await service(.failure(.cancelled), steamReply: nil, account: account)
        service.signOut()
        #expect(account.steamID == nil)
        #expect(account.hasAPIKey)
    }
}
