import Foundation
import Observation

/// State and actions for a single game's detail screen.
@MainActor
@Observable
final class GameDetailViewModel {
    /// The game being shown.
    let game: Game
    /// Last error to surface, if any.
    var errorMessage: String?

    private let repository: any LibraryRepository
    private let hltb: (any HLTBProviding)?

    /// Creates the view model. When `hltb` is supplied, the main-story estimate is shown as a labelled HLTB row.
    init(game: Game, repository: any LibraryRepository, hltb: (any HLTBProviding)? = nil) {
        self.game = game
        self.repository = repository
        self.hltb = hltb
    }

    /// Per-source playtime; never merged. HLTB appears only as its own labelled estimate row.
    var breakdown: PlaytimeBreakdown {
        game.playtimeBreakdown(hltbEstimateSeconds: hltb?.cachedEstimate(for: game.id)?.seconds(for: .mainStory))
    }

    /// Sessions, newest first.
    var sessions: [PlaySession] {
        game.sessions.sorted { $0.startedAt > $1.startedAt }
    }

    /// Current status.
    var status: GameStatus {
        get { game.status }
        set {
            game.updateStatus(newValue)
            persist()
        }
    }

    /// Self-reported hours (editable). Zero clears the value.
    var selfReportedHours: Double {
        get { game.selfReportedSeconds.map(DurationFormatting.hours(seconds:)) ?? 0 }
        set {
            let seconds = DurationFormatting.seconds(hours: max(0, newValue))
            game.selfReportedSeconds = seconds > 0 ? seconds : nil
            persist()
        }
    }

    /// Sets or clears the cover image path.
    func setCoverImagePath(_ path: String?) {
        game.coverImagePath = path
        persist()
    }

    private func persist() {
        do {
            try repository.save()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
