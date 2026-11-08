import Foundation

/// The fields Retriever reads from the Steam store `appdetails` payload (snake_case keys converted).
struct SteamStoreAppDetails: Decodable, Sendable {
    /// Store type ("game", "dlc", …).
    let type: String?
    /// Store name.
    let name: String?
    /// Short plain description (may contain entities).
    let shortDescription: String?
    /// Long HTML description.
    let aboutTheGame: String?
    /// Developers.
    let developers: [String]?
    /// Genres.
    let genres: [SteamStoreDescribedItem]?
    /// Store categories (Single-player, Steam Achievements, …), used as tags.
    let categories: [SteamStoreDescribedItem]?
    /// Release date.
    let releaseDate: SteamStoreReleaseDate?
    /// Wide header capsule (460×215).
    let headerImage: String?
    /// Store page background without the blur overlay.
    let backgroundRaw: String?
    /// Screenshots.
    let screenshots: [SteamStoreScreenshot]?
    /// Trailers (only thumbnails are used).
    let movies: [SteamStoreMovie]?
}
