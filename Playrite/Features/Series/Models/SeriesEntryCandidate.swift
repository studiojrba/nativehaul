import Foundation

/// Something that can be added to a series: a library game or a collection's sub-game.
enum SeriesEntryCandidate: Identifiable, Hashable {
    /// A standalone game.
    case game(Game)
    /// A sub-game inside a collection.
    case subGame(SubGame)

    /// Identity across both kinds.
    var id: UUID {
        switch self {
        case let .game(game): game.id
        case let .subGame(subGame): subGame.id
        }
    }

    /// Picker title.
    @MainActor var title: String {
        switch self {
        case let .game(game): game.title
        case let .subGame(subGame): "\(subGame.title) — \(subGame.collection?.name ?? "Collection")"
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
