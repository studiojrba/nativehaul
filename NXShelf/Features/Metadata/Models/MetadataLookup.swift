import Foundation

/// A provider's answer for one game.
enum MetadataLookup: Equatable, Sendable {
    /// A confident match (by app ID, or a single exact normalised-title match).
    case found(FetchedMetadata)
    /// Nothing matched exactly.
    case noMatch
    /// Several different titles matched; left blank rather than risk the wrong game's art.
    case ambiguous
    /// The provider can't be used (for example, no SteamGridDB key).
    case unavailable
}
