import Foundation

/// What the onboarding scan really found in the chosen folders (spec §3.6 `found`, §6: the actual scan count).
struct OnboardingScan: Equatable, Sendable {
    /// Games in the folders.
    let gameCount: Int
    /// Their titles, A–Z.
    let titles: [String]
    /// Up to a shelf's worth of them, those with cover art first.
    let covers: [ScanCover]
    /// Whether the folder couldn't be read.
    var isUnreadable = false

    /// Whether anything was found.
    var hasGames: Bool {
        gameCount >= 1
    }

    /// Nothing found.
    static let empty = OnboardingScan(gameCount: 0, titles: [], covers: [])
}
