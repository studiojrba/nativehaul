import Foundation

/// One beat of the onboarding conversation (spec §3.6, 0.1.1 order): one question at a time. The games folder and its
/// scan come first, then the Switch build tutorial (with where builds go and the library key), then the emulators,
/// then couch or desk, then the closing beat.
enum OnboardingBeat: String, CaseIterable, Sendable {
    /// "Hey there. I'm nativehaul." plus the trust beat.
    case welcome
    /// Where the games live.
    case games
    /// What the scan found.
    case found
    /// "The big feature here: you can build your Switch games natively with nxnative."
    case buildIntro
    /// One folder for base games, updates and DLC.
    case buildFolder
    /// Press Begin build; the stages are progress labels.
    case buildBegin
    /// Where Switch builds go.
    case install
    /// Launching a finished build, and where nxnative comes from.
    case buildLaunch
    /// "Good to know": a first-time hitch while the Mac gets a new effect ready.
    case buildNote
    /// The library key.
    case keys
    /// What the library key is (no sources, no tools).
    case keysHelp
    /// The emulators found on this Mac, and the offer to set up others.
    case player
    /// The chosen emulators installing from their official sources.
    case playerInstall
    /// Couch or desk.
    case final
    /// The closing beat: Settings keeps the door open, happy gaming.
    case closing

    /// The beats under each progress dot, in order.
    static let steps: [[OnboardingBeat]] = [
        [.welcome], [.games], [.found],
        [.buildIntro, .buildFolder, .buildBegin, .install, .buildLaunch, .buildNote, .keys, .keysHelp],
        [.player, .playerInstall], [.final], [.closing],
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
        case .buildIntro, .buildFolder, .buildBegin, .buildLaunch, .buildNote: .build
        case .install: .disk
        case .keys, .keysHelp: .keys
        case .player, .playerInstall: .player
        case .final: .couch
        case .closing: .closing
        }
    }
}
