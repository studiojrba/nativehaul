import Foundation

/// The systems nativehaul can identify for RetroAchievements (ADR 0047): cartridge systems whose hash rule is a plain
/// or
/// lightly normalised MD5. Disc-based and DS games use RetroAchievements' more involved hashing and aren't identified
/// yet; they simply show no achievements.
enum RetroAchievementsSystem {
    /// RetroAchievements' console ID and hash rule for `system`, or `nil` when nativehaul can't identify its games.
    static func identification(for system: EmulatedSystem) -> (consoleID: Int, rule: RomHashRule)? {
        switch system {
        case .gameBoy: (Console.gameBoy, .wholeFile)
        case .gameBoyColor: (Console.gameBoyColor, .wholeFile)
        case .gameBoyAdvance: (Console.gameBoyAdvance, .wholeFile)
        case .nes: (Console.nes, .nes)
        case .snes: (Console.snes, .snes)
        case .nintendo64: (Console.nintendo64, .nintendo64)
        default: nil
        }
    }

    /// RetroAchievements console IDs.
    private enum Console {
        static let nintendo64 = 2
        static let snes = 3
        static let gameBoy = 4
        static let gameBoyAdvance = 5
        static let gameBoyColor = 6
        static let nes = 7
    }
}
