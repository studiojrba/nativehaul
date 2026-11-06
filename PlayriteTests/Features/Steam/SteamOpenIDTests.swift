import Foundation
@testable import Playrite
import Testing

struct SteamOpenIDTests {
    private let configuration = SteamOpenIDFixtures.configuration

    @Test func loginURLAsksSteamToPickTheIdentity() throws {
        let url = try #require(SteamOpenID.loginURL(configuration))
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let query = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
        #expect(url.host() == "steamcommunity.com")
        #expect(query["openid.mode"] == "checkid_setup")
        #expect(query["openid.identity"] == SteamOpenID.identifierSelect)
        #expect(query["openid.return_to"] == configuration.returnTo)
        #expect(query["openid.realm"] == configuration.realm)
        #expect(query["openid.return_to"] == "http://127.0.0.1:51234/steam-openid/callback")
        #expect(query["openid.realm"] == "http://127.0.0.1:51234/")
    }

    @Test func returnAddressesAreAlwaysHTTPLoopbackNeverACustomScheme() throws {
        let configuration = try #require(SteamOpenIDConfiguration.loopback(port: 61000))
        let returnTo = try #require(URL(string: configuration.returnTo))
        #expect(returnTo.scheme == "http")
        #expect(returnTo.host() == "127.0.0.1")
        #expect(returnTo.port == 61000)
        #expect(returnTo.path() == SteamOpenIDConfiguration.callbackPath)
        #expect(configuration.returnTo.hasPrefix(configuration.realm))
    }

    @Test func validReplyYieldsTheSteamID() throws {
        let assertion = try SteamOpenIDResponseValidator.validate(
            SteamOpenIDFixtures.callback(),
            configuration: configuration
        )
        #expect(assertion.steamID.rawValue == SteamOpenIDFixtures.steamID)
        #expect(assertion.parameters["openid.sig"] == "W0u+Ab/cd=")
    }

    @Test func cancelledReplyIsCancelled() {
        #expect(throws: SteamSignInError.cancelled) {
            try SteamOpenIDResponseValidator.validate(
                SteamOpenIDFixtures.callback(["openid.mode": "cancel"]),
                configuration: configuration
            )
        }
    }

    @Test(arguments: [
        ["openid.op_endpoint": "https://evil.example/openid/login"],
        ["openid.return_to": "http://127.0.0.1:9/steam-openid/callback"],
        ["openid.signed": "signed,claimed_id,identity"],
        ["openid.sig": nil],
    ] as [[String: String?]])
    func untrustedRepliesAreRejected(overrides: [String: String?]) {
        #expect(throws: SteamSignInError.untrustedResponse) {
            try SteamOpenIDResponseValidator.validate(
                SteamOpenIDFixtures.callback(overrides),
                configuration: configuration
            )
        }
    }

    @Test(arguments: [
        ["openid.identity": "https://steamcommunity.com/openid/id/76561197960287931"],
        [
            "openid.claimed_id": "https://evil.example/openid/id/76561197960287930",
            "openid.identity": "https://evil.example/openid/id/76561197960287930"
        ],
        [
            "openid.claimed_id": "https://steamcommunity.com/openid/id/123",
            "openid.identity": "https://steamcommunity.com/openid/id/123"
        ],
    ] as [[String: String?]])
    func badIdentitiesAreRejected(overrides: [String: String?]) {
        #expect(throws: SteamSignInError.invalidIdentity) {
            try SteamOpenIDResponseValidator.validate(
                SteamOpenIDFixtures.callback(overrides),
                configuration: configuration
            )
        }
    }

    @Test func notAnOpenIDReplyIsRejected() {
        #expect(throws: SteamSignInError.notASteamResponse) {
            try SteamOpenIDResponseValidator.validate(
                SteamOpenIDFixtures.callback(["openid.ns": nil]),
                configuration: configuration
            )
        }
    }

    @Test func verifierAsksSteamWithCheckAuthentication() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "openid/login", json: "ns:http://specs.openid.net/auth/2.0\nis_valid:true\n")
        let assertion = try SteamOpenIDResponseValidator.validate(
            SteamOpenIDFixtures.callback(),
            configuration: configuration
        )
        try await SteamOpenIDVerifier(http: http).confirm(assertion, configuration: configuration)
        let request = try #require(await http.requests.first)
        let body = String(decoding: request.httpBody ?? Data(), as: UTF8.self)
        #expect(request.httpMethod == "POST")
        #expect(body.contains("openid.mode=check_authentication"))
        #expect(body.contains("openid.sig=W0u%2BAb%2Fcd%3D"))
        #expect(!body.contains("id_res"))
    }

    @Test func verifierTreatsAnythingButIsValidTrueAsRejected() async throws {
        let http = MockHTTPClient()
        await http.stub(urlContaining: "openid/login", json: "ns:http://specs.openid.net/auth/2.0\nis_valid:false\n")
        let assertion = try SteamOpenIDResponseValidator.validate(
            SteamOpenIDFixtures.callback(),
            configuration: configuration
        )
        await #expect(throws: SteamSignInError.rejectedBySteam) {
            try await SteamOpenIDVerifier(http: http).confirm(assertion, configuration: configuration)
        }
    }

    @Test func verifierReportsUnreachableSteam() async throws {
        let http = MockHTTPClient()
        let assertion = try SteamOpenIDResponseValidator.validate(
            SteamOpenIDFixtures.callback(),
            configuration: configuration
        )
        await #expect(throws: SteamSignInError.couldNotConfirm) {
            try await SteamOpenIDVerifier(http: http).confirm(assertion, configuration: configuration)
        }
    }
}
