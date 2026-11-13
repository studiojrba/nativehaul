import Foundation

extension OnboardingScript {
    /// The build tutorial's words (notes 8, 10, 11, 13). No internal terms: the user gives nativehaul one folder and
    /// presses Begin build; the stages are progress labels. nativehaul never downloads or bundles nxnative (ADR 0027),
    /// so the trust line says exactly that. The "Good to know" note promises no shader pre-warming (ADR 0059).
    static func buildMessages(for beat: OnboardingBeat, facts: OnboardingFacts) -> [String] {
        switch beat {
        case .install: install(facts)
        case .keys: keys(facts)
        case .keysHelp: keysHelp
        case .buildIntro:
            ["The big feature here: you can build your Switch games natively with nxnative.", "Here’s how it works:"]
        case .buildFolder:
            ["Keep your base games, updates and DLC together in one folder. I’ll sort them all out for you."]
        case .buildBegin:
            ["Then press Begin build. I’ll take it from there and show you every step as it happens."]
        case .buildLaunch:
            [
                "When it’s ready, launch it from the same shelf with one click or one controller press.",
                "And nxnative stays yours: I use your own copy on this Mac. I never bundle it, repackage it or "
                    + "download it from anywhere else.",
            ]
        case .buildNote:
            [
                "Good to know: the first time a game shows a new area or effect, it can hitch for a moment while "
                    + "your Mac gets it ready.",
                "That usually only happens the first time. After that it plays smoothly.",
            ]
        default:
            []
        }
    }

    /// Where builds go (the build tutorial's "one tidy spot").
    static func install(_ facts: OnboardingFacts) -> [String] {
        let lead = "Each finished build lives in one tidy spot."
        guard let volume = facts.installVolume else {
            return [lead, "The default spot is \(abbreviate(facts.installLocation))."]
        }
        let free = volume.freeGigabytes
        if free < snugGigabytes {
            return [lead, "Your Mac has \(free) GB free. That’s a bit snug, so an external drive could help."]
        }
        return [lead, "Your Mac has \(free) GB free, so the default spot has plenty of room."]
    }

    /// The library key (note 4: never the file's real name, never "Switch keys").
    static func keys(_ facts: OnboardingFacts) -> [String] {
        let lead = "One more thing for Switch builds: your library key."
        if facts.detectedKeys != nil {
            return ["Found your library key already. Lovely."]
        }
        return [lead, "It comes from your own console and lets me build your Switch games. It never leaves this Mac."]
    }

    /// The library key explainer: what it is, never where to get it (CLAUDE.md, user-provided files).
    static let keysHelp = [
        "No worries. It’s only needed for Switch builds, and it comes from your own console.",
        "Once you have it, drop it right here. I’ll wait, or skip it for now.",
    ]

    /// The explainer's steps card. The file's real kind (a `.keys` file) appears only here, as the help detail.
    static let keysSteps = [
        "1. Find the library key from your own console (a .keys file).",
        "2. Drop it here.",
        "3. That’s it. It stays on this Mac.",
    ]
}
