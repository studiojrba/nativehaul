import Foundation

/// One official Nintendo eShop listing, as returned by a ``NintendoStoreSearching`` source.
///
/// Packshot fields are deliberately absent: Nintendo's portrait images are box renders with rating badges, which
/// the official-art-only rule excludes. Only the wide key art is used.
struct NintendoStoreHit: Decodable, Equatable, Sendable {
    /// Stable listing identifier.
    let listingID: String
    /// Listing title.
    let title: String
    /// Listing description (may contain HTML).
    let description: String?
    /// Developer.
    let developer: String?
    /// Genres.
    let genres: [String]?
    /// ISO-8601 or store-formatted release date.
    let releaseDate: String?
    /// Official wide key art URL.
    let keyArtURL: String?
    /// Platform names ("Nintendo Switch").
    let platforms: [String]?

    /// Whether the listing is for Switch (listings without platform data are kept).
    var isSwitch: Bool {
        let platforms = platforms ?? []
        return platforms.isEmpty || platforms.contains { $0.localizedCaseInsensitiveContains("switch") }
    }
}
