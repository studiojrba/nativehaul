import Foundation

/// Identifiers of every badge Retriever can award.
enum BadgeID: String, CaseIterable, Sendable {
    case firstCompletion
    case tenCompletions
    case marathonSession
    case centurion
    case seriesFinisher
    case collectionComplete
    case nativeExplorer
    case weekStreak
    case perfectAchievements
}
