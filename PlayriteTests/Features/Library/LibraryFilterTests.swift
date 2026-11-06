@testable import Playrite
import Testing

@MainActor
struct LibraryFilterTests {
    private func games() -> [Game] {
        [
            Game(title: "zeta", status: .playing),
            Game(title: "Alpha", status: .backlog),
            Game(title: "Éclair", status: .completed),
        ]
    }

    @Test func allSectionSortsByTitle() {
        let result = LibraryFilter().apply(to: games())
        #expect(result.map(\.title) == ["Alpha", "Éclair", "zeta"])
    }

    @Test func sectionFiltersByStatus() {
        let result = LibraryFilter(section: .playing).apply(to: games())
        #expect(result.map(\.title) == ["zeta"])
    }

    @Test func searchIsDiacriticInsensitive() {
        let result = LibraryFilter(searchText: " eclair ").apply(to: games())
        #expect(result.map(\.title) == ["Éclair"])
    }
}
