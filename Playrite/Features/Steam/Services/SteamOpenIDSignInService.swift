import Foundation

/// Live ``SteamSigningIn`` over Steam OpenID 2.0: open Steam's page, check the reply locally, have Steam confirm it
/// with `check_authentication`, then store the SteamID64.
@MainActor
final class SteamOpenIDSignInService: SteamSigningIn {
    private let configuration: SteamOpenIDConfiguration
    private let authenticator: any SteamWebAuthenticating
    private let verifier: SteamOpenIDVerifier
    private let account: any SteamAccountStoring

    /// Creates the service.
    init(
        configuration: SteamOpenIDConfiguration = .standard,
        authenticator: any SteamWebAuthenticating,
        verifier: SteamOpenIDVerifier,
        account: any SteamAccountStoring
    ) {
        self.configuration = configuration
        self.authenticator = authenticator
        self.verifier = verifier
        self.account = account
    }

    func signIn() async throws -> SteamID {
        guard let loginURL = SteamOpenID.loginURL(configuration) else { throw SteamSignInError.notASteamResponse }
        let callback = try await authenticator.authenticate(url: loginURL, callbackScheme: configuration.callbackScheme)
        let assertion = try SteamOpenIDResponseValidator.validate(callback, configuration: configuration)
        try await verifier.confirm(assertion, configuration: configuration)
        account.saveSteamID(assertion.steamID)
        return assertion.steamID
    }

    func signOut() {
        account.saveSteamID(nil)
    }
}
