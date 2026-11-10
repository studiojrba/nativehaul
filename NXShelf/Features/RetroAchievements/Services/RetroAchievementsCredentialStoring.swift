import Foundation

/// The optional RetroAchievements credentials (ADR 0047). Live: ``RetroAchievementsCredentialStore`` (Keychain);
/// mock: ``MockRetroAchievementsCredentialStore``.
protocol RetroAchievementsCredentialStoring: Sendable {
    /// Both values, or `nil` unless both are stored.
    func credentials() -> RetroAchievementsCredentials?
    /// Saves both (blank values remove them).
    func save(username: String, apiKey: String) throws
    /// Removes both.
    func remove() throws
}
