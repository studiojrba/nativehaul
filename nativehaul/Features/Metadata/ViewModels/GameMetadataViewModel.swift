import Foundation
import Observation

/// Manage sheet → Metadata: shows where each field came from and runs an explicit refresh for one game.
@MainActor
@Observable
final class GameMetadataViewModel {
    /// The game.
    let game: Game
    /// Whether a refresh is running.
    private(set) var isRefreshing = false
    /// Result of the last refresh.
    private(set) var statusMessage: String?

    private let fetcher: any MetadataFetching
    private let onChanged: @MainActor () -> Void

    /// Creates the view model.
    init(game: Game, fetcher: any MetadataFetching, onChanged: @escaping @MainActor () -> Void = {}) {
        self.game = game
        self.fetcher = fetcher
        self.onChanged = onChanged
    }

    /// One row per field that has a recorded source.
    var sourceRows: [(field: MetadataField, source: MetadataSource)] {
        let provenance = game.metadataProvenance
        return provenance.recordedFields.compactMap { field in provenance[field].map { (field, $0) } }
    }

    /// Re-fetches this game's metadata. User-set fields and manual art are kept.
    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            let summary = try await fetcher.refresh(game)
            statusMessage = summary.gamesUpdated > 0 ? "Metadata refreshed." : "Nothing new found."
            onChanged()
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
