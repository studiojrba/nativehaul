import Foundation
@testable import NXShelf
import Testing

@MainActor
struct GameStatusTests {
    @Test func completingStampsAndReopeningClears() {
        let game = Game(title: "A")
        let date = Date(timeIntervalSince1970: 1000)
        game.updateStatus(.completed, at: date)
        #expect(game.completedAt == date)
        game.updateStatus(.playing)
        #expect(game.completedAt == nil)
    }

    @Test func unknownRawValueFallsBack() {
        let game = Game(title: "A")
        game.statusRaw = "nonsense"
        game.platformRaw = "nonsense"
        #expect(game.status == .backlog)
        #expect(game.platform == .other)
    }
}
