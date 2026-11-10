import Foundation

/// The signed-in account's public name and avatar, from `GetPlayerSummaries`.
struct SteamProfileSummary: Equatable, Sendable {
    /// Display name.
    let personaName: String
    /// Avatar image URL (shown only after it has been downloaded).
    let avatarURL: URL?
    /// `false` when the whole profile is private, which also hides game details.
    let isProfilePublic: Bool
}
