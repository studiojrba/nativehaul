import Foundation

/// Mock ``SteamWebAuthenticating`` returning a canned callback (or error). Records the URLs it was asked to open.
@MainActor
final class MockSteamWebAuthenticator: SteamWebAuthenticating {
    private let result: Result<URL, SteamSignInError>
    /// URLs opened so far.
    private(set) var openedURLs: [URL] = []

    /// Creates the mock.
    init(result: Result<URL, SteamSignInError>) {
        self.result = result
    }

    func authenticate(url: URL, callbackScheme _: String) async throws -> URL {
        openedURLs.append(url)
        return try result.get()
    }
}
