import Foundation

/// "Sign in through Steam". Proves which Steam account is the user's and stores its SteamID64 — it grants no
/// access to the library. Live: ``SteamOpenIDSignInService``; mock: ``MockSteamSignInService``.
@MainActor
protocol SteamSigningIn: AnyObject {
    /// Runs the sign-in and stores the confirmed SteamID64.
    func signIn() async throws -> SteamID
    /// Forgets the linked SteamID64 (the API key, if any, stays in the Keychain).
    func signOut()
}
