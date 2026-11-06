import Foundation

/// Live ``SteamSigningIn`` over Steam OpenID 2.0: run the browser round trip through a loopback listener, check the
/// reply locally, have Steam confirm it with `check_authentication`, then store the SteamID64.
@MainActor
final class SteamOpenIDSignInService: SteamSigningIn {
    private let browser: any SteamBrowserSigningIn
    private let verifier: SteamOpenIDVerifier
    private let account: any SteamAccountStoring

    /// Creates the service.
    init(browser: any SteamBrowserSigningIn, verifier: SteamOpenIDVerifier, account: any SteamAccountStoring) {
        self.browser = browser
        self.verifier = verifier
        self.account = account
    }

    func signIn() async throws -> SteamID {
        let (callback, configuration) = try await browser.callback()
        let assertion = try SteamOpenIDResponseValidator.validate(callback, configuration: configuration)
        try await verifier.confirm(assertion, configuration: configuration)
        account.saveSteamID(assertion.steamID)
        return assertion.steamID
    }

    func signOut() {
        account.saveSteamID(nil)
    }
}
