import Foundation
@testable import nativehaul
import Testing

/// Spec §3.3 "Also on your shelf": the user's own games, related first, backfilled, at most three, never itself.
@MainActor
struct RelatedGamesTests {
    @Test func sharedGenreOrStudioComeFirstThenTheRest() throws {
        let fixture = try GameFixture()
        let game = fixture.game("Here", developer: "Studio A", genres: ["Puzzle"])
        let other = fixture.game("Other", genres: ["Racing"])
        let genre = fixture.game("Same genre", genres: ["puzzle", "Co-op"])
        let studio = fixture.game("Same studio", developer: "studio a")
        let library = [game, other, genre, studio]
        #expect(RelatedGames.games(for: game, in: library).map(\.title) == ["Same genre", "Same studio", "Other"])
    }

    @Test func atMostThreeAndNeverItself() throws {
        let fixture = try GameFixture()
        let library = (0 ..< 6).map { fixture.game("Game \($0)") }
        let related = RelatedGames.games(for: library[0], in: library)
        #expect(related.count == RelatedGames.limit)
        #expect(!related.contains { $0.id == library[0].id })
        #expect(RelatedGames.games(for: library[0], in: [library[0]]).isEmpty)
    }
}
