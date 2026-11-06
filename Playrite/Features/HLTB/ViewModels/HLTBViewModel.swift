import Foundation
import Observation

/// HLTB estimates for one game. Every figure is labelled "HLTB estimate".
@MainActor
@Observable
final class HLTBViewModel {
    /// The game.
    let game: Game
    /// Whether the cached figures are older than the cache lifetime.
    private(set) var isStale = false
    /// Note from the last lookup (e.g. no official API).
    private(set) var note: String?
    /// Last save error.
    private(set) var errorMessage: String?

    private let service: any HLTBProviding
    private let opener: any URLOpening

    /// Creates the view model.
    /// Why the HLTB cache couldn't be read, if it couldn't.
    var loadProblem: String? {
        service.loadProblem
    }

    init(game: Game, service: any HLTBProviding, opener: any URLOpening) {
        self.game = game
        self.service = service
        self.opener = opener
    }

    /// Current cached estimate.
    var estimate: HLTBEstimate? {
        service.cachedEstimate(for: game.id)
    }

    /// Labelled rows for display.
    var rows: [(category: HLTBCategory, text: String)] {
        HLTBCategory.allCases.compactMap { category in
            estimate?.labelledText(for: category).map { (category, $0) }
        }
    }

    /// Asks the data layer for fresh data (falls back to cache).
    func refresh() async {
        let result = await service.lookup(gameID: game.id, title: game.title)
        isStale = result.isStale
        note = result.note
    }

    /// Saves figures entered in hours. Zero or blank clears a category.
    func saveManual(hours: [HLTBCategory: Double]) {
        do {
            try service.saveManual(
                gameID: game.id, title: game.title,
                seconds: hours.mapValues { DurationFormatting.seconds(hours: max(0, $0)) }
            )
            isStale = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Opens the game's HowLongToBeat page (when its HLTB id is known) or a title search, in the browser.
    func openSearch() {
        if let url = game.hltbID.flatMap(HLTBLink.gameURL(id:)) ?? service.searchURL(for: game.title) {
            opener.open(url)
        }
    }
}
