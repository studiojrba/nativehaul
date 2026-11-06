import Foundation

/// A Steam store trailer. Only its official thumbnail is used; video is never downloaded.
struct SteamStoreMovie: Decodable, Sendable {
    /// Thumbnail image URL.
    let thumbnail: String?
}
