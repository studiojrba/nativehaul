import Foundation
import Observation

/// Tracking controls on a game's detail screen, including self-reported session logging.
@MainActor
@Observable
final class TrackedAppViewModel {
    /// The game.
    let game: Game
    /// Last error.
    private(set) var errorMessage: String?

    private let repository: any LibraryRepository
    private let watcher: any PlaytimeWatching

    /// Creates the view model.
    init(game: Game, repository: any LibraryRepository, watcher: any PlaytimeWatching) {
        self.game = game
        self.repository = repository
        self.watcher = watcher
    }

    /// Tracked bundle path, if any.
    var bundlePath: String? {
        game.appBundlePath
    }

    /// Links an `.app` bundle to this game.
    func setBundle(_ url: URL) {
        perform { game.appBundlePath = BundlePath.normalize(url.path) }
    }

    /// Stops tracking. Existing sessions are kept.
    func clearBundle() {
        perform { game.appBundlePath = nil }
    }

    /// Logs a manual session with source ``PlaytimeSource/selfReported``. Non-positive durations are ignored.
    func logSelfReportedSession(startedAt: Date, hours: Double) {
        let seconds = DurationFormatting.seconds(hours: hours)
        guard seconds > 0 else { return }
        perform {
            let session = PlaySession(
                startedAt: startedAt,
                endedAt: startedAt.addingTimeInterval(TimeInterval(seconds)),
                source: .selfReported
            )
            repository.insert(session)
            session.game = game
        }
    }

    private func perform(_ change: () -> Void) {
        change()
        do {
            try repository.save()
            watcher.refreshTrackedApps()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
