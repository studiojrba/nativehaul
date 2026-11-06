import Foundation

/// Live ``SteamBrowserSigningIn``: start a one-shot listener on 127.0.0.1, build the OpenID request for its port, open
/// it in the user's browser, wait for the redirect, then shut the listener down.
@MainActor
final class LoopbackSteamBrowserSignIn: SteamBrowserSigningIn {
    /// How long to wait for the user to finish in the browser.
    static let defaultTimeout = Duration.seconds(defaultTimeoutSeconds)
    private static let defaultTimeoutSeconds = 300

    private let opener: any URLOpening
    private let timeout: Duration
    private let makeServer: @MainActor () -> LoopbackCallbackServer

    /// Creates the sign-in.
    init(
        opener: any URLOpening,
        timeout: Duration = defaultTimeout,
        makeServer: @escaping @MainActor () -> LoopbackCallbackServer = {
            LoopbackCallbackServer(callbackPath: SteamOpenIDConfiguration.callbackPath)
        }
    ) {
        self.opener = opener
        self.timeout = timeout
        self.makeServer = makeServer
    }

    func callback() async throws -> (url: URL, configuration: SteamOpenIDConfiguration) {
        let server = makeServer()
        defer { server.stop() }
        let port: UInt16
        do {
            port = try await server.start()
        } catch {
            throw SteamSignInError.couldNotListen
        }
        guard let configuration = SteamOpenIDConfiguration.loopback(port: port),
              let loginURL = SteamOpenID.loginURL(configuration)
        else { throw SteamSignInError.notASteamResponse }
        opener.open(loginURL)
        do {
            return try await (server.waitForCallback(timeout: timeout), configuration)
        } catch LoopbackCallbackError.timedOut {
            throw SteamSignInError.timedOut
        } catch LoopbackCallbackError.couldNotListen {
            throw SteamSignInError.couldNotListen
        } catch {
            throw SteamSignInError.cancelled
        }
    }
}
