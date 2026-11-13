import Foundation

/// The conversation's words for each beat (spec §3.6, final copy in ADR 0057), written from the real facts: the real
/// scan count and titles, the real free space, the keys file already found, the players really installed. Never mock
/// data. Actions are in `OnboardingScript+Actions`.
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
        case .install: install(facts)
        case .keys: keys(facts)
        case .keysHelp: keysHelp
        case .player: player(facts)
        case .final: ["You’re all set up.", "Want to chill on the couch with a controller?"]
        }
    }

    /// Page 1.
    static let welcome = [
        "Hey there. I’m nativehaul.",
        "I keep your Switch games and your emulator classics on a nice shelf and launch them for you, at the desk or "
            + "on the couch.",
        "Mind if I ask a few quick things? It takes about a minute.",
    ]

    /// The keys explainer: what it is, never where to get it (CLAUDE.md, user-provided files).
    static let keysHelp = [
        "No worries. It’s only needed for Switch builds, and it comes from your own console.",
        "Once you have it, drop it right here. I’ll wait — or skip it for now.",
    ]

    /// The keys explainer's steps card.
    static let keysSteps = [
        "1. Find the prod.keys file from your own console.",
        "2. Drop it here.",
        "3. That’s it — it stays on this Mac.",
    ]

    private static func games(_ facts: OnboardingFacts) -> [String] {
        guard !facts.configuredFolders.isEmpty else {
            return [
                "First up: where do your games live?",
                "Point me at the folder with your Switch games and emulator ROMs and I’ll have a look.",
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
                "That’s fine. Drop Switch ports or ROMs in there any time and I’ll pick them up.",
            ]
        }
        let noun = scan.gameCount == 1 ? "game" : "games"
        return ["Ooh. \(scan.gameCount) \(noun) in \(folder).", taste(scan.titles)]
    }

    /// "{A}, {B}, {C}… you've got excellent taste." from up to three real titles.
    static func taste(_ titles: [String]) -> String {
        "\(titles.prefix(tasteTitleCount).joined(separator: ", "))… you’ve got excellent taste."
    }

    private static func install(_ facts: OnboardingFacts) -> [String] {
        let lead = "When I build one of your Switch games, I need somewhere cosy to put it."
        guard let volume = facts.installVolume else {
            return [lead, "The default spot is \(abbreviate(facts.installLocation))."]
        }
        let free = volume.freeGigabytes
        if free < snugGigabytes {
            return [lead, "Your Mac has \(free) GB free. That’s a bit snug, so an external drive could help."]
        }
        return [lead, "Your Mac has \(free) GB free, so the default spot has plenty of room."]
    }

    private static func keys(_ facts: OnboardingFacts) -> [String] {
        let lead = "Now the slightly nerdy bit: your Switch keys file."
        if facts.detectedKeys != nil {
            return [lead, "Found your keys file already. Lovely."]
        }
        return [lead, "It comes from your own console and lets me build your Switch games. It never leaves this Mac."]
    }

    private static func player(_ facts: OnboardingFacts) -> [String] {
        var lines: [String] = []
        switch facts.keysOutcome {
        case .placed: lines.append("Got it — your keys file is in place.")
        case .alreadyThere: lines.append("There was already a keys file in that spot, so I kept that one.")
        case .skipped: lines.append("No problem. Switch builds can wait until you have it.")
        case .failed: lines.append("I couldn’t copy that file, so let’s leave it for now. You can add it in Settings.")
        case nil: break
        }
        guard !facts.players.isEmpty else {
            return lines + [
                "Last bit of plumbing: I didn’t find any emulator apps or the nxnative engine on this Mac yet.",
                "That’s okay. When a game needs one, I’ll say which, right there.",
            ]
        }
        return lines + [
            "Last bit of plumbing: I found \(playerList(facts.players)) on this Mac.",
            "I’ll open each game in the right one. You can change that in Settings any time.",
        ]
    }

    /// "RetroArch, Dolphin and the nxnative engine".
    static func playerList(_ players: [DetectedPlayer]) -> String {
        let names = players.map { $0.kind == .buildEngine ? "the nxnative engine" : $0.name }
        return naturalList(names)
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

    private static func naturalList(_ items: [String]) -> String {
        guard let last = items.last, items.count > 1 else { return items.first ?? "" }
        return items.dropLast().joined(separator: ", ") + " and " + last
    }
}
