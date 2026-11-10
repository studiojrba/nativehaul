import Foundation

/// Steam store release date block.
struct SteamStoreReleaseDate: Decodable, Sendable {
    /// `true` while unreleased; the date is then not used.
    let comingSoon: Bool?
    /// Free-form date ("18 Apr, 2011").
    let date: String?
}
