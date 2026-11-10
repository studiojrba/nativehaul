import Foundation
@testable import NXShelf
import Testing

@MainActor
struct LibraryViewModelTests {
    private func makeViewModel(seeded: Bool = false) throws -> (LibraryViewModel, MockLibraryRepository) {
        let repository = try MockLibraryRepository(seeded: seeded)
        let viewModel = LibraryViewModel(repository: repository, transfer: MockLibraryTransferService())
        viewModel.reload()
        return (viewModel, repository)
    }

    @Test func addTrimsAndIgnoresBlank() throws {
        let (viewModel, repository) = try makeViewModel()
        viewModel.addGame(title: "   ", platform: .switchPort, status: .backlog)
        viewModel.addGame(title: "  Tideborn ", platform: .switchPort, status: .playing)
        #expect(viewModel.games.map(\.title) == ["Tideborn"])
        #expect(repository.saveCount == 1)
    }

    @Test func countsPerSection() throws {
        let (viewModel, _) = try makeViewModel(seeded: true)
        #expect(viewModel.count(for: .all) == 3)
        #expect(viewModel.count(for: .playing) == 1)
        #expect(viewModel.count(for: .backlog) == 1)
        #expect(viewModel.count(for: .completed) == 1)
    }

    @Test func setStatusMovesGameBetweenSections() throws {
        let (viewModel, _) = try makeViewModel(seeded: true)
        let game = try #require(viewModel.games.first { $0.status == .backlog })
        viewModel.setStatus(.completed, for: game)
        #expect(viewModel.count(for: .completed) == 2)
        #expect(game.completedAt != nil)
    }

    @Test func deleteRemovesGame() throws {
        let (viewModel, _) = try makeViewModel(seeded: true)
        let game = try #require(viewModel.games.first)
        viewModel.delete(game)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.games.count == 2)
    }

    @Test func importRecordsSummary() throws {
        let repository = try MockLibraryRepository()
        let transfer = MockLibraryTransferService()
        transfer.importResult = ImportSummary(gamesAdded: 2)
        let viewModel = LibraryViewModel(repository: repository, transfer: transfer)
        viewModel.importLibrary(from: Data("{}".utf8))
        #expect(viewModel.importSummary?.gamesAdded == 2)
        #expect(transfer.importedPayloads.count == 1)
    }
}
