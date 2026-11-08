import Foundation

/// Where a metadata field's current value came from. Values with no recorded source came from a library import
/// (or predate this feature) and are treated as imported.
enum MetadataSource: String, Codable, CaseIterable, Sendable {
    /// Steam store `appdetails` (official).
    case steamStore
    /// Nintendo's official eShop listing.
    case nintendoStore
    /// SteamGridDB (fallback artwork, needs the user's key).
    case steamGridDB
    /// Set by hand in Retriever (Choose Cover…, Choose Hero Image…). Never overwritten.
    case user

    /// Sources a Fetch Missing Metadata pass queries, in priority order.
    static let fetchOrder: [MetadataSource] = [.steamStore, .nintendoStore, .steamGridDB]

    /// Whether the value was downloaded by a metadata pass (and so may be replaced by an explicit refresh).
    var isFetched: Bool {
        self != .user
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .steamStore: "Steam store"
        case .nintendoStore: "Nintendo eShop"
        case .steamGridDB: "SteamGridDB"
        case .user: "Set by you"
        }
    }
}
