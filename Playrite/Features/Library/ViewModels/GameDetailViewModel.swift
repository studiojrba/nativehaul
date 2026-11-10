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

    /// Details info list (Status, Install Size, Time Played, …).
    var infoRows: [GameInfoRow] {
        GameInfoBuilder.rows(for: game)
    }

    /// Real playtime only, per source (paired with the HLTB bar, ADR 0039).
    var playtime: PlaytimeBreakdown {
        game.playtimeBreakdown()
    }

    /// The HLTB bar, or `nil` when no estimate is cached.
    var hltbBar: HLTBBar? {
        HLTBBar(estimate: hltb?.cachedEstimate(for: game.id), breakdown: playtime)
    }

    /// The lead and full description (ADR 0039).
    var description: DetailDescription {
        DetailDescription(summary: game.summary)
    }

    /// Specs table rows, only where data exists.
    var specRows: [GameSpecRow] {
        GameSpecRow.rows(for: game)
    }

    /// What the case prints, or `nil` without cover art.
    var caseArtwork: CaseArtwork? {
        CaseArtwork.make(for: game)
    }

    /// HLTB chips (Main Story / Main Story+ / Completionist), each labelled as an estimate in the view.
    var hltbChips: [HLTBChip] {
        HLTBChip.chips(for: hltb?.cachedEstimate(for: game.id))
    }

    /// Sets or clears the hero image path. A chosen image is marked as set by the user, so metadata passes never
    /// replace it.
    func setHeroImagePath(_ path: String?) {
        game.heroImagePath = path
        markManual(.hero, isSet: path != nil)
        persist()
    }

    /// Sets or clears the cover image path. A chosen image is marked as set by the user.
    func setCoverImagePath(_ path: String?) {
        game.coverImagePath = path
        markManual(.cover, isSet: path != nil)
        persist()
    }

    private func markManual(_ field: MetadataField, isSet: Bool) {
        var provenance = game.metadataProvenance
        provenance[field] = isSet ? .user : nil
        game.metadataProvenance = provenance
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
