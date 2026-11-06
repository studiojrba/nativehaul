import Foundation

/// A game owned on Steam, as returned by `IPlayerService/GetOwnedGames`.
struct SteamOwnedGame: Decodable, Equatable, Sendable {
    /// Steam application ID.
    let appid: Int
    /// Title (present when `include_appinfo=1`).
    let name: String?
    /// Lifetime playtime in minutes.
    let playtimeForever: Int
    /// Unix timestamp of last play, `0` when never played.
    let rtimeLastPlayed: Int?
}
