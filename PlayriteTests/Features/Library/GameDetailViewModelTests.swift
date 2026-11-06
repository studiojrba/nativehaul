@testable import Playrite
import Testing

@MainActor
struct GameDetailViewModelTests {
    @Test func selfReportedHoursRoundTripAndClear() throws {
        let repository = try MockLibraryRepository()
        let game = Game(title: "A")
        repository.insert(game)
        let viewModel = GameDetailViewModel(game: game, repository: repository)
        viewModel.selfReportedHours = 2.5
        #expect(game.selfReportedSeconds == 9000)
        #expect(viewModel.breakdown.seconds(for: .selfReported) == 9000)
        viewModel.selfReportedHours = 0
        #expect(game.selfReportedSeconds == nil)
        #expect(repository.saveCount == 2)
    }
}
