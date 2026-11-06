import Foundation
@testable import Playrite
import Testing

@MainActor
struct CollectionDetailViewModelTests {
    @Test func subGamesHaveIndependentStatuses() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let collection = try #require(try repository.fetchCollections().first)
        let viewModel = CollectionDetailViewModel(collection: collection, repository: repository)
        let second = viewModel.subGames[1]
        viewModel.setStatus(.playing, for: second)
        #expect(viewModel.subGames.map(\.status) == [.completed, .playing, .backlog])
    }

    @Test func addMoveRemove() throws {
        let repository = try MockLibraryRepository()
        let collection = GameCollection(name: "Trilogy")
        repository.insert(collection)
        let viewModel = CollectionDetailViewModel(collection: collection, repository: repository)
        ["A", "B", "C", " "].forEach(viewModel.addSubGame)
        #expect(viewModel.subGames.map(\.title) == ["A", "B", "C"])
        viewModel.move(fromOffsets: IndexSet(integer: 0), toOffset: 3)
        #expect(viewModel.subGames.map(\.title) == ["B", "C", "A"])
        viewModel.remove(atOffsets: IndexSet(integer: 1))
        #expect(viewModel.subGames.map(\.title) == ["B", "A"])
    }

    @Test func parentGameSelection() throws {
        let repository = try MockLibraryRepository(seeded: true)
        let collection = try #require(try repository.fetchCollections().first)
        let viewModel = CollectionDetailViewModel(collection: collection, repository: repository)
        let target = try #require(viewModel.parentCandidates.first { $0.title == "Tideborn" })
        viewModel.parentGameID = target.id
        #expect(collection.parentGame?.title == "Tideborn")
        viewModel.parentGameID = nil
        #expect(collection.parentGame == nil)
    }

    @Test func collectionsListAddDelete() throws {
        let repository = try MockLibraryRepository()
        let viewModel = CollectionsViewModel(repository: repository)
        viewModel.addCollection(name: "Box")
        #expect(viewModel.collections.count == 1)
        try viewModel.delete(#require(viewModel.collections.first))
        #expect(viewModel.collections.isEmpty)
    }
}
