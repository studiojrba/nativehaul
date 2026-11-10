import Foundation

/// The RetroAchievements username and web API key the user pasted (ADR 0047). Kept only in the Keychain.
struct RetroAchievementsCredentials: Equatable, Sendable {
    /// Username (whose progress is shown).
    let username: String
    /// Web API key (from the user's RetroAchievements control panel).
    let apiKey: String
}
