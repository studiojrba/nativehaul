import Foundation

/// Where a metadata field's current value came from. Values with no recorded source came from a library import
/// (or predate this feature) and are treated as imported.
enum MetadataSource: String, Codable, CaseIterable, Sendable {
    /// Nintendo eShop data from titledb (official descriptions, screenshots and key art), joined by title ID.
    case titleDB
    /// IGDB (needs the user's Twitch credentials): YouTube trailers, screenshots and summaries for Switch ports.
    case igdb
    /// SteamGridDB (fallback artwork, needs the user's key).
    case steamGridDB
    /// Set by hand in NX Shelf (Choose Cover…, Choose Hero Image…). Never overwritten.
    case user

    /// Sources a Fetch Missing Metadata pass queries, in priority order.
    static let fetchOrder: [MetadataSource] = [.titleDB, .igdb, .steamGridDB]

    /// Whether the value was downloaded by a metadata pass (and so may be replaced by an explicit refresh).
    var isFetched: Bool {
        self != .user
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .titleDB: "Nintendo eShop (titledb)"
        case .igdb: "IGDB"
        case .steamGridDB: "SteamGridDB"
        case .user: "Set by you"
        }
    }
}
