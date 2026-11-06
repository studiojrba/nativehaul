import Foundation

/// Result of matching a title against a provider's search results.
enum TitleMatch<ID: Hashable & Sendable>: Equatable, Sendable {
    /// Exactly one distinct result matched the normalised title.
    case unique(ID)
    /// No result matched exactly.
    case none
    /// Several distinct results matched.
    case ambiguous

    /// Picks the single result whose name normalises to the same key as `title`. Near misses never match.
    static func resolve(title: String, among candidates: [(id: ID, name: String)]) -> TitleMatch<ID> {
        let ids = Set(candidates.filter { TitleNormalizer.matches($0.name, title) }.map(\.id))
        switch ids.count {
        case 0: return .none
        case 1: return ids.first.map(TitleMatch.unique) ?? .none
        default: return .ambiguous
        }
    }
}
