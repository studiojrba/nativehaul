import Foundation

/// ``RetroAchievementsProviding`` for previews and tests: a fixed answer.
struct MockRetroAchievementsService: RetroAchievementsProviding {
    /// The answer for every ROM.
    var result: RetroAchievementsLookup = .unavailable

    func lookup(romPath _: String, system _: EmulatedSystem, knownGameID _: Int?) async -> RetroAchievementsLookup {
        result
    }
}
