import Foundation

/// The optional IGDB credentials (ADR 0038). Live: ``IGDBCredentialStore`` (Keychain); mock:
/// ``MockIGDBCredentialStore``.
protocol IGDBCredentialStoring: Sendable {
    /// Both credentials, or `nil` unless both are stored.
    func credentials() -> IGDBCredentials?
    /// Saves both (blank values remove them).
    func save(clientID: String, clientSecret: String) throws
    /// Removes both.
    func remove() throws
}
