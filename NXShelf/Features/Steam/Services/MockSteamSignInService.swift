import Foundation

/// Mock ``SteamSigningIn`` for previews: signs in as a fixed sample account.
@MainActor
final class MockSteamSignInService: SteamSigningIn {
    private static let sampleSteamID = "76561197960287930"
    private let account: any SteamAccountStoring

    /// Creates the mock over an account store.
    init(account: any SteamAccountStoring) {
        self.account = account
    }

    func signIn() async throws -> SteamID {
        guard let steamID = SteamID(Self.sampleSteamID) else { throw SteamSignInError.invalidIdentity }
        account.saveSteamID(steamID)
        return steamID
    }

    func signOut() {
        account.saveSteamID(nil)
    }
}
