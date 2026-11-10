import Foundation

/// What RetroAchievements has for a game (ADR 0047).
enum RetroAchievementsLookup: Equatable, Sendable {
    /// No credentials: the feature is silently absent.
    case unavailable
    /// NX Shelf can't identify this system's games yet.
    case unsupportedSystem
    /// The ROM's hash isn't in RetroAchievements (or the ROM couldn't be read).
    case notFound
    /// The user's progress in the matched set.
    case found(RetroAchievementsProgress)
    /// The service didn't answer (offline, rate-limited, refused key).
    case failed
}
