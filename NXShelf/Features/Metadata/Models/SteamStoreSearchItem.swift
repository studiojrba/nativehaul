import Foundation

/// One `storesearch` result.
struct SteamStoreSearchItem: Decodable, Sendable {
    /// Result type; only "app" is used.
    let type: String?
    /// Store name.
    let name: String
    /// Steam app ID.
    let id: Int
}
