import Foundation

/// One player from `GetPlayerSummaries`.
struct SteamPlayer: Decodable, Sendable {
    private static let publicVisibility = 3

    /// Display name.
    let personaname: String
    /// Full-size avatar URL.
    let avatarfull: String?
    /// 1 = private, 3 = public.
    let communityvisibilitystate: Int?

    /// The app's summary of this player.
    var summary: SteamProfileSummary {
        SteamProfileSummary(
            personaName: personaname,
            avatarURL: avatarfull.flatMap(URL.init(string:)),
            isProfilePublic: communityvisibilitystate == Self.publicVisibility
        )
    }
}
