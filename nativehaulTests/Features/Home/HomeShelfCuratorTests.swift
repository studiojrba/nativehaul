import Foundation
@testable import nativehaul
import Testing

/// Note 14: Home's curated shelves come from the user's own library only, each hides itself below three games, and a
/// shelf with no data behind it (no genres, no release dates) stays hidden rather than guessing.
@MainActor
struct HomeShelfCuratorTests {
    private let now = Date(timeIntervalSince1970: 1_794_500_000)
    private let day: TimeInterval = 86400

    private func game(
        _ title: String,
        addedDaysAgo: Double = 100,
        genres: [String] = [],
        tags: [String] = [],
        released: Date? = nil
    ) -> Game {
        let game = Game(title: title, releaseDate: released, addedAt: now.addingTimeInterval(-addedDaysAgo * day))
        game.genres = genres
        game.tags = tags
        return game
    }

    @Test func aLibraryWithNoMetadataShowsOnlyFreshAndNotStarted() {
        let library = (1 ... 18).map { game("Game \($0)", addedDaysAgo: 1) }
        let shelves = HomeShelfCurator.shelves(from: library, jumpBackIn: [], now: now)
        #expect(shelves.map(\.kind) == [.fresh, .notStarted])
        #expect(shelves.allSatisfy { $0.games.count <= HomeShelfCurator.maximumGames })
    }

    @Test func aShelfWithFewerThanThreeGamesHidesItself() {
        let library = [game("A", addedDaysAgo: 1), game("B", addedDaysAgo: 1), game("C")]
        let kinds = HomeShelfCurator.shelves(from: library, jumpBackIn: [], now: now).map(\.kind)
        #expect(!kinds.contains(.fresh))
        #expect(kinds.contains(.notStarted))
    }

    @Test func cosyFriendsAndBrandNewUseRealGenresTagsAndDates() {
        let recent = now.addingTimeInterval(-200 * day)
        let library = [
            game("Farm", genres: ["Simulator"], released: recent),
            game("Puzzle Box", genres: ["Puzzle"], tags: ["Co-op"], released: recent),
            game("Island", genres: ["Life sim"], tags: ["Multiplayer"], released: recent),
            game("Party Night", genres: ["Party"], tags: ["Local multiplayer"]),
            game("Old Classic", genres: ["Shooter"], released: Date(timeIntervalSince1970: 0)),
        ]
        let shelves = HomeShelfCurator.shelves(from: library, jumpBackIn: [], now: now)
        let byKind = Dictionary(uniqueKeysWithValues: shelves.map { ($0.kind, $0.games.map(\.title)) })
        #expect(Set(byKind[.cosy] ?? []) == ["Farm", "Puzzle Box", "Island"])
        #expect(Set(byKind[.friends] ?? []) == ["Puzzle Box", "Island", "Party Night"])
        #expect(Set(byKind[.brandNew] ?? []) == ["Farm", "Puzzle Box", "Island"])
        let brandNew = shelves.first { $0.kind == .brandNew }
        #expect(brandNew.flatMap { shelf in shelf.games.first.flatMap(shelf.badge(for:)) } != nil)
    }

    @Test func suggestionsShareAGenreWithWhatIsBeingPlayed() {
        let playing = game("Now", genres: ["Roguelike"])
        let library = [playing] + (1 ... 3).map { game("Rogue \($0)", genres: ["Roguelike"]) }
            + [game("Other", genres: ["Racing"])]
        let suggestions = HomeShelfCurator.members(of: .suggestions, from: library, jumpBackIn: [playing], now: now)
        #expect(suggestions.map(\.title).sorted() == ["Rogue 1", "Rogue 2", "Rogue 3"])
    }

    @Test func noHighestRatedShelfExistsWithoutRatings() {
        #expect(!HomeShelfKind.allCases.map(\.eyebrow).contains("Highest rated"))
    }

    @Test func theWholeShelfLineNeverSaysZeroHours() {
        let summary = ShelfSummary(games: [game("A"), game("B")])
        #expect(summary.wholeShelfLine == "2 games, ready when you are.")
        #expect(!summary.librarySubtitle.contains("0 hours"))
    }
}
