import Foundation

/// Steam store `storesearch` response.
struct SteamStoreSearchResponse: Decodable, Sendable {
    /// Results.
    let items: [SteamStoreSearchItem]?
}
