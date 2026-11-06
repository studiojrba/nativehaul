import Foundation

/// Shows Steam's sign-in page and returns the callback URL Steam redirects to.
/// Live: ``WebAuthenticationSessionRunner``; mock: ``MockSteamWebAuthenticator``.
@MainActor
protocol SteamWebAuthenticating: AnyObject {
    /// Opens `url` and waits for a redirect to `callbackScheme`. Throws ``SteamSignInError/cancelled`` when closed.
    func authenticate(url: URL, callbackScheme: String) async throws -> URL
}
