import Foundation
import Observation

/// Stats page: counts, hours per source, completion and badges.
@MainActor
@Observable
final class StatsViewModel {
    /// Latest statistics.
    private(set) var stats = StatsCalculator.stats(for: .empty)
    /// Latest badge results.
    private(set) var badges: [BadgeResult] = []
    /// Last error.
    private(set) var errorMessage: String?

    private let provider: any LibrarySnapshotProviding
    private let engine: BadgeEngine

    /// Creates the view model.
    init(provider: any LibrarySnapshotProviding, engine: BadgeEngine = BadgeEngine()) {
        self.provider = provider
        self.engine = engine
    }

    /// Completion as a whole percentage string, e.g. "42%".
    var completionText: String {
        stats.completionFraction.formatted(.percent.precision(.fractionLength(0)))
    }

    /// Hours per real source in canonical order, omitting empty sources.
    var hoursBySource: [PlaytimeEntry] {
        PlaytimeSource.allCases.compactMap { source in
            stats.secondsBySource[source].map { PlaytimeEntry(source: source, seconds: $0) }
        }
    }

    /// Number of earned badges.
    var earnedCount: Int {
        badges.count(where: \.isEarned)
    }

    /// Recomputes everything from the library.
    func reload() {
        do {
            let snapshot = try provider.snapshot()
            stats = StatsCalculator.stats(for: snapshot)
            badges = engine.evaluate(snapshot)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
