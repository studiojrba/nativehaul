import Foundation

/// A recently played game from `IPlayerService/GetRecentlyPlayedGames`.
struct SteamRecentGame: Decodable, Equatable, Sendable, Identifiable {
    /// Steam application ID.
    let appid: Int
    /// Title.
    let name: String?
    /// Minutes played in the last two weeks.
    let playtime2Weeks: Int?
    /// Lifetime playtime in minutes.
    let playtimeForever: Int

    /// Identity for lists.
    var id: Int {
        appid
    }
}
