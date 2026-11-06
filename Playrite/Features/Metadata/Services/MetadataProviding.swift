import Foundation

/// A metadata source (Steam store, Nintendo eShop, SteamGridDB). Live implementations talk HTTP through an injected
/// ``HTTPClient``; ``MockMetadataProvider`` serves previews and tests.
protocol MetadataProviding: Sendable {
    /// Which source this is.
    var source: MetadataSource { get }
    /// Whether this source should be asked about a game at all (for example, Nintendo only for Switch games).
    func applies(to query: MetadataQuery) -> Bool
    /// Looks the game up. Matches by app ID first, then by exact normalised title; never fuzzily.
    func lookup(_ query: MetadataQuery) async throws -> MetadataLookup
}

extension MetadataProviding {
    func applies(to _: MetadataQuery) -> Bool {
        true
    }
}
