import Foundation

/// One beat of the onboarding conversation (spec §3.6): one question at a time.
enum OnboardingBeat: String, CaseIterable, Sendable {
    /// "Hey there. I'm nativehaul."
    case welcome
    /// Where the games live.
    case games
    /// What the scan found.
    case found
    /// Where Switch builds go.
    case install
    /// The Switch keys file.
    case keys
    /// What the keys file is (no sources, no tools).
    case keysHelp
    /// The players found on this Mac.
    case player
    /// Couch or desk.
    case final

    /// The beats under each progress dot, in order (`found` counts as `games`, `keysHelp` as `keys`).
    static let steps: [[OnboardingBeat]] = [
        [.welcome], [.games, .found], [.install], [.keys, .keysHelp], [.player], [.final],
    ]

    /// How many progress dots the top bar shows.
    static let stepCount = steps.count

    /// This beat's progress dot.
    var step: Int {
        Self.steps.firstIndex { $0.contains(self) } ?? 0
    }

    /// The preview scene on the right.
    var scene: OnboardingScene {
        switch self {
        case .welcome: .welcome
        case .games, .found: .shelf
        case .install: .disk
        case .keys, .keysHelp: .keys
        case .player: .player
        case .final: .couch
        }
    }
}
