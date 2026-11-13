import Foundation
@testable import nativehaul
import Testing

/// Spec §3.0: the top bar's live search.
@MainActor
struct GameSearchTests {
    @Test func matchesTitleStudioAndGenreCaseInsensitively() throws {
        let fixture = try GameFixture()
        let games = [
            fixture.game("Lantern Coast", developer: "Tidewater"),
            fixture.game("Ironleaf", genres: ["Metroidvania"]),
            fixture.game("Quiet Orbit"),
        ]
        #expect(GameSearch.results(for: "lantern", in: games).map(\.title) == ["Lantern Coast"])
        #expect(GameSearch.results(for: "TIDE", in: games).map(\.title) == ["Lantern Coast"])
        #expect(GameSearch.results(for: "metroid", in: games).map(\.title) == ["Ironleaf"])
        #expect(GameSearch.results(for: "nothing", in: games).isEmpty)
        #expect(GameSearch.results(for: "   ", in: games).isEmpty)
    }

    @Test func showsAtMostFive() throws {
        let fixture = try GameFixture()
        let games = (1 ... 8).map { fixture.game("Game \($0)") }
        #expect(GameSearch.results(for: "game", in: games).count == GameSearch.maximumResults)
        #expect(GameSearch.maximumResults == 5)
    }
}
