import Foundation
@testable import nativehaul

/// Shared couch test data: shelves of named items and contexts.
enum CouchFixtures {
    /// `count` items titled from `titles` (cycled) with fresh IDs.
    static func items(_ titles: [String]) -> [CouchItem] {
        titles.map { CouchItem(id: UUID(), title: $0) }
    }

    /// `count` items titled "Game 0"….
    static func items(count: Int) -> [CouchItem] {
        items((0 ..< count).map { "Game \($0)" })
    }

    /// Home with a three-game hero, a ten-tile shelf and a three-tile shelf, four tiles visible.
    static func homeContext(heroCount: Int = 3) -> CouchContext {
        CouchContext(
            heroCount: heroCount,
            shelves: [
                CouchShelf(title: "Continue playing", items: items(count: 10)),
                CouchShelf(title: "Everything, A–Z", items: items(count: 3)),
            ],
            visibleCount: 4
        )
    }
}
