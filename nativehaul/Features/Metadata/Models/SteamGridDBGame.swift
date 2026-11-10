import Foundation

/// A SteamGridDB game.
struct SteamGridDBGame: Decodable, Sendable {
    /// SteamGridDB game ID.
    let id: Int
    /// Game name.
    let name: String
}
