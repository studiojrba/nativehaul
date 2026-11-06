import Foundation

/// What a provider needs to look a game up. A value copy, so it can cross into provider tasks.
struct MetadataQuery: Equatable, Sendable {
    /// Library identifier.
    let gameID: UUID
    /// Display title (matched with ``TitleNormalizer`` only — never fuzzily).
    let title: String
    /// Steam app ID, when known. Always tried before the title.
    let steamAppID: Int?
    /// Library platform.
    let platform: GamePlatform
}
