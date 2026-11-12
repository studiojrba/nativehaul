import Foundation
@testable import nativehaul
import Testing

/// ADR 0052: TV shelves are Recently Played first, then Switch, Emulated and Other, each A–Z, with empty ones left out.
@MainActor
struct TVShelfTests {
    private static let hour: TimeInterval = 3600

    @Test func shelvesComeInPlanOrderAndSortAToZ() {
        let zelda = Game(title: "Zelda", platform: .switchPort)
        let mario = Game(title: "Mario", platform: .switchPort)
        let metroid = Game(title: "Metroid Fusion", platform: .emulated)
        mario.lastPlayedAt = .now
        zelda.lastPlayedAt = .now.addingTimeInterval(-Self.hour)
        let shelves = TVShelf.shelves(from: [zelda, metroid, mario])
        #expect(shelves.map(\.id) == ["recent", "switch", "emulated"])
        #expect(shelves[0].games.map(\.title) == ["Mario", "Zelda"])
        #expect(shelves[1].games.map(\.title) == ["Mario", "Zelda"])
        #expect(shelves[2].games.map(\.title) == ["Metroid Fusion"])
    }

    @Test func recentlyPlayedIsCapped() {
        let games = (0 ..< 5).map { index -> Game in
            let game = Game(title: "Game \(index)", platform: .switchPort)
            game.lastPlayedAt = .now.addingTimeInterval(-Double(index) * Self.hour)
            return game
        }
        let recent = TVShelf.shelves(from: games, recentLimit: 3).first
        #expect(recent?.games.map(\.title) == ["Game 0", "Game 1", "Game 2"])
    }

    @Test func anEmptyLibraryHasNoShelves() {
        #expect(TVShelf.shelves(from: []).isEmpty)
    }
}
