import Foundation

/// Opens Steam's sign-in page in the user's browser and waits for Steam's redirect.
/// Live: ``LoopbackSteamBrowserSignIn``; mock: ``MockSteamBrowserSignIn``.
@MainActor
protocol SteamBrowserSigningIn: AnyObject {
    /// Runs the browser round trip and returns Steam's callback URL with the configuration it was made for.
    func callback() async throws -> (url: URL, configuration: SteamOpenIDConfiguration)
}
