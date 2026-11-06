import Foundation

/// Evaluates badges strictly from real recorded data in a ``LibrarySnapshot``.
///
/// HLTB estimates are never used. Every earned badge carries evidence pointing at the data that earned it.
struct BadgeEngine: Sendable {
    private let calendar: Calendar

    /// Creates an engine. `calendar` decides day boundaries for streaks.
    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Evaluates every badge in ``BadgeCatalog``.
    func evaluate(_ snapshot: LibrarySnapshot) -> [BadgeResult] {
        BadgeCatalog.all.map { definition in
            let (value, evidence) = measure(definition.id, in: snapshot)
            return BadgeResult(definition: definition, progress: min(value, definition.target), evidence: evidence)
        }
    }

    private func measure(_ id: BadgeID, in snapshot: LibrarySnapshot) -> (Int, String?) {
        let games = snapshot.games
        switch id {
        case .firstCompletion, .tenCompletions:
            let completed = games.filter { $0.status == .completed }
            return (completed.count, completed.first?.title)
        case .marathonSession:
            let game = games
                .first {
                    $0.sessions.contains { !$0.source.isEstimate && $0.durationSeconds >= BadgeCatalog.marathonSeconds }
                }
            return (game == nil ? 0 : 1, game?.title)
        case .centurion:
            let game = games.first { $0.realSecondsBySource.values.contains { $0 >= BadgeCatalog.centurionSeconds } }
            return (game == nil ? 0 : 1, game?.title)
        case .seriesFinisher:
            let minimumEntries = 2
            let finished = snapshot.seriesEntryStatuses
                .contains { $0.count >= minimumEntries && $0.allSatisfy { $0 == .completed } }
            return (finished ? 1 : 0, nil)
        case .collectionComplete:
            let complete = snapshot.collectionStatuses.contains { !$0.isEmpty && $0.allSatisfy { $0 == .completed } }
            return (complete ? 1 : 0, nil)
        case .nativeExplorer:
            let game = games.first { $0.platform == .switchPort && $0.sessions.contains { $0.source == .macTracked } }
            return (game == nil ? 0 : 1, game?.title)
        case .weekStreak:
            return (longestDailyStreak(games.flatMap(\.sessions)), nil)
        case .perfectAchievements:
            let game = games.first { game in
                guard let total = game.steamAchievementsTotal, total > 0 else { return false }
                return game.steamAchievementsUnlocked == total
            }
            return (game == nil ? 0 : 1, game?.title)
        }
    }

    /// Longest run of consecutive calendar days with at least one real session.
    func longestDailyStreak(_ sessions: [SessionSnapshot]) -> Int {
        let days = Set(sessions.filter { !$0.source.isEstimate }.map { calendar.startOfDay(for: $0.startedAt) })
            .sorted()
        var longest = 0
        var current = 0
        var previous: Date?
        for day in days {
            if let previous, calendar.date(byAdding: .day, value: 1, to: previous) == day {
                current += 1
            } else {
                current = 1
            }
            longest = max(longest, current)
            previous = day
        }
        return longest
    }
}
