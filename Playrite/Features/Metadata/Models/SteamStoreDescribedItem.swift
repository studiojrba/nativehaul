import Foundation

/// A Steam store genre or category (`{"id": …, "description": "Action"}`). Only the description is read, since
/// the `id` is a string for genres and a number for categories.
struct SteamStoreDescribedItem: Decodable, Sendable {
    /// Display name.
    let description: String
}
