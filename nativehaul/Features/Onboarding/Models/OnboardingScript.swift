import Foundation

/// The conversation's words for each beat (spec §3.6, final copy in ADR 0057, 0.1.1 order in ADR 0059), written from
/// the real facts: the real scan count and titles, the real free space, the library key already found, the emulators
/// really installed. Never mock data. The build tutorial's words are in `OnboardingScript+Build`, the emulators' and
/// the ending's in `OnboardingScript+Players`, and the actions in `OnboardingScript+Actions`.
enum OnboardingScript {
    /// Below this much free space the install line suggests an external drive.
    static let snugGigabytes = 20
    /// Up to this many folders are named; more are counted.
    static let namedFolderLimit = 2
    /// How many titles the "excellent taste" line names.
    static let tasteTitleCount = 3

    /// The app's messages for `beat`.
    static func messages(for beat: OnboardingBeat, facts: OnboardingFacts) -> [String] {
        switch beat {
        case .welcome: welcome
        case .games: games(facts)
        case .found: found(facts)
        case .buildIntro, .buildFolder, .buildBegin, .install, .buildLaunch, .buildNote, .keys, .keysHelp:
            buildMessages(for: beat, facts: facts)
        case .player: player(facts)
        case .playerInstall: playerInstall
        case .final: ["You’re all set up.", "Want to chill on the couch with a controller?"]
        case .closing: closing
        }
    }

    /// Page 1, with the trust beat. Every line is true in the build (ADR 0059): nativehaul has no entitlements and asks
    /// for no Accessibility, Full Disk Access, Input Monitoring or Screen Recording. "I'm open source" is held back
    /// until the public repository carries the licence on its default branch.
    static let welcome = [
        "Hey there. I’m nativehaul.",
        "I keep your Switch games and your emulator classics on a nice shelf and launch them for you, at the desk or "
            + "on the couch.",
        "A few things worth knowing: I only ask for what I actually need, nothing extra.",
        "And you’re in full control the whole way.",
    ]

    /// Said as soon as the folder is confirmed, before the typing dots hold for the scan.
    static let scanning = "Perfect, running a quick scan in here, one sec."

    /// The waiting bubble's text for assistive tech (it shows only typing dots).
    static let scanningPlaceholder = "Scanning your games folder…"

    private static func games(_ facts: OnboardingFacts) -> [String] {
        guard !facts.configuredFolders.isEmpty else {
            return [
                "First up: where do your games live?",
                "Point me at the folder with your Switch files and emulator ROMs and I’ll have a look.",
            ]
        }
        return [
            "First up: your games. I’m already looking in \(folderList(facts.configuredFolders)).",
            "Want me to look somewhere else too?",
        ]
    }

    private static func found(_ facts: OnboardingFacts) -> [String] {
        let folder = facts.scannedFolderLabel ?? "your folder"
        let scan = facts.scan ?? .empty
        if scan.isUnreadable {
            return ["I couldn’t open \(folder).", "You can pick a different folder in Settings whenever you like."]
        }
        guard scan.hasGames else {
            return [
                "Hmm, no games in \(folder) yet.",
                "That’s fine. Drop Switch files or ROMs in there any time and I’ll pick them up.",
            ]
        }
        let noun = scan.gameCount == 1 ? "game" : "games"
        return ["Ooh. \(scan.gameCount) \(noun) in \(folder).", taste(scan.titles)]
    }

    /// "{A}, {B}, {C}… you've got excellent taste." from up to three real titles.
    static func taste(_ titles: [String]) -> String {
        "\(titles.prefix(tasteTitleCount).joined(separator: ", "))… you’ve got excellent taste."
    }

    /// "~/Games", "~/Games and ~/ROMs", "~/Games and 2 other folders".
    static func folderList(_ folders: [String]) -> String {
        let labels = folders.map(abbreviate)
        guard let first = labels.first else { return "your folders" }
        guard labels.count > namedFolderLimit else { return naturalList(labels) }
        return "\(first) and \(labels.count - 1) other folders"
    }

    /// A home-abbreviated path.
    static func abbreviate(_ path: String) -> String {
        ((path as NSString).expandingTildeInPath as NSString).abbreviatingWithTildeInPath
    }

    /// "A", "A and B", "A, B and C".
    static func naturalList(_ items: [String]) -> String {
        guard let last = items.last, items.count > 1 else { return items.first ?? "" }
        return items.dropLast().joined(separator: ", ") + " and " + last
    }
}
