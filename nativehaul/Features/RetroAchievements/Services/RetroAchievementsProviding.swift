import Foundation

/// Finds a ROM's RetroAchievements set and the user's progress (ADR 0047). Live: ``RetroAchievementsService``;
/// mock: ``MockRetroAchievementsService``.
protocol RetroAchievementsProviding: Sendable {
    /// What RetroAchievements has for the ROM at `romPath` on `system`. `knownGameID` skips hashing when an earlier
    /// lookup already matched.
    func lookup(romPath: String, system: EmulatedSystem, knownGameID: Int?) async -> RetroAchievementsLookup
}
