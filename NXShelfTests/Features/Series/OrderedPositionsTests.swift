import Foundation
@testable import NXShelf
import Testing

struct OrderedPositionsTests {
    @Test func moveAndRenumber() {
        var positions: [String: Int] = [:]
        let moved = OrderedPositions.moved(["a", "b", "c"], fromOffsets: IndexSet(integer: 2), toOffset: 0)
        OrderedPositions.renumber(moved) { positions[$0] = $1 }
        #expect(moved == ["c", "a", "b"])
        #expect(positions == ["c": 0, "a": 1, "b": 2])
    }

    @Test func nextPosition() {
        #expect(OrderedPositions.nextPosition(after: []) == 0)
        #expect(OrderedPositions.nextPosition(after: [0, 5, 2]) == 6)
    }
}
