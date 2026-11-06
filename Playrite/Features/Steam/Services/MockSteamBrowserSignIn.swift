import Foundation

/// Mock ``SteamBrowserSigningIn`` returning a canned callback (or error) for a fixed loopback port.
@MainActor
final class MockSteamBrowserSignIn: SteamBrowserSigningIn {
    /// Port the canned callback pretends to use.
    nonisolated static let port: UInt16 = 51234
    private let result: Result<URL, SteamSignInError>
    /// Number of sign-ins started.
    private(set) var startCount = 0

    /// Creates the mock.
    init(result: Result<URL, SteamSignInError>) {
        self.result = result
    }

    func callback() async throws -> (url: URL, configuration: SteamOpenIDConfiguration) {
        startCount += 1
        guard let configuration = SteamOpenIDConfiguration.loopback(port: Self.port) else {
            throw SteamSignInError.couldNotListen
        }
        return try (result.get(), configuration)
    }
}
