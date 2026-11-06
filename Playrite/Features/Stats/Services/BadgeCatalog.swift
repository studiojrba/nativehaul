import Foundation

/// The fixed set of badge definitions.
enum BadgeCatalog {
    private static let tenCompletionsTarget = 10
    private static let marathonHours = 4
    private static let centurionHours = 100
    private static let streakDays = 7

    /// Hours for the marathon session badge.
    static var marathonSeconds: Int {
        marathonHours * secondsPerHour
    }

    /// Hours on one game, in one real source, for the centurion badge.
    static var centurionSeconds: Int {
        centurionHours * secondsPerHour
    }

    private static let secondsPerHour = 3600

    /// All badges in display order.
    static let all: [BadgeDefinition] = [
        BadgeDefinition(
            id: .firstCompletion,
            title: "First Credits",
            criteria: "Mark a game as completed.",
            symbolName: "flag.checkered",
            target: 1
        ),
        BadgeDefinition(
            id: .tenCompletions, title: "Credits Collector", criteria: "Complete 10 games.",
            symbolName: "rosette", target: tenCompletionsTarget
        ),
        BadgeDefinition(
            id: .marathonSession, title: "Marathon",
            criteria: "Record a single real session of \(marathonHours) hours or more (MacTracked or SelfReported).",
            symbolName: "figure.run", target: 1
        ),
        BadgeDefinition(
            id: .centurion, title: "Centurion",
            criteria: "Reach \(centurionHours) hours on one game in a single real source (estimates never count).",
            symbolName: "100.circle", target: 1
        ),
        BadgeDefinition(
            id: .seriesFinisher, title: "Saga Complete",
            criteria: "Complete every entry of a series with at least two entries.", symbolName: "books.vertical.fill",
            target: 1
        ),
        BadgeDefinition(
            id: .collectionComplete, title: "Box Set",
            criteria: "Complete every game in a collection.", symbolName: "square.stack.3d.up.fill", target: 1
        ),
        BadgeDefinition(
            id: .nativeExplorer, title: "Native Explorer",
            criteria: "Record a MacTracked session on a Switch native port.", symbolName: "macbook.and.iphone",
            target: 1
        ),
        BadgeDefinition(
            id: .weekStreak, title: "Seven-Day Streak",
            criteria: "Record real sessions on \(streakDays) consecutive days.", symbolName: "calendar",
            target: streakDays
        ),
        BadgeDefinition(
            id: .perfectAchievements, title: "Perfectionist",
            criteria: "Unlock every Steam achievement in a game.", symbolName: "star.circle.fill", target: 1
        ),
    ]
}
