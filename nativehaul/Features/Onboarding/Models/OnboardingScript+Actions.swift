import Foundation

extension OnboardingScript {
    /// The actions under `beat`, primary first. Only real choices: "Use my external drive" exists only when a drive is
    /// mounted, the library key ask is skipped when the file is already here, skipping is always one click, and the
    /// emulator offer exists only when there is something to set up.
    static func actions(for beat: OnboardingBeat, facts: OnboardingFacts) -> [OnboardingAction] {
        switch beat {
        case .welcome:
            [OnboardingAction(id: "start", label: "Sure, let’s go", isPrimary: true, effect: .advance(.games))]
        case .games:
            gamesActions(facts)
        case .found:
            [OnboardingAction(id: "next", label: foundReply(facts), isPrimary: true, effect: .advance(.buildIntro))]
        case .buildIntro, .buildFolder, .buildBegin, .buildLaunch, .buildNote:
            buildActions(beat)
        case .install:
            installActions(facts)
        case .keys, .keysHelp:
            keysActions(beat, facts: facts)
        case .player, .playerInstall:
            playerActions(beat, facts: facts)
        case .final:
            [
                OnboardingAction(
                    id: "couch",
                    label: "Couch mode, please",
                    isPrimary: true,
                    effect: .chooseMode(.couch)
                ),
                OnboardingAction(id: "desktop", label: "I’ll stick with desktop", effect: .chooseMode(.desktop)),
            ]
        case .closing:
            [OnboardingAction(id: "play", label: "Let’s play", isPrimary: true, effect: .finish)]
        }
    }

    private static func gamesActions(_ facts: OnboardingFacts) -> [OnboardingAction] {
        if !facts.configuredFolders.isEmpty {
            return [
                OnboardingAction(id: "keep", label: "That’s everything", isPrimary: true, effect: .keepFolders),
                OnboardingAction(id: "pick", label: "Add another folder", effect: .pickFolder),
            ]
        }
        if let folder = facts.suggestedFolder {
            return [
                OnboardingAction(
                    id: "suggested",
                    label: "Use \(abbreviate(folder))",
                    isPrimary: true,
                    effect: .useFolder(folder)
                ),
                OnboardingAction(id: "pick", label: "I’ll show you", effect: .pickFolder),
            ]
        }
        return [
            OnboardingAction(id: "pick", label: "I’ll show you", isPrimary: true, effect: .pickFolder),
            OnboardingAction(id: "later", label: "I’ll add them later", effect: .advance(.buildIntro)),
        ]
    }

    private static func foundReply(_ facts: OnboardingFacts) -> String {
        let scan = facts.scan ?? .empty
        return scan.hasGames && !scan.isUnreadable ? "Ha, thanks. What’s next?" : "Okay, what’s next?"
    }

    private static func buildActions(_ beat: OnboardingBeat) -> [OnboardingAction] {
        let (label, next): (String, OnboardingBeat) = switch beat {
        case .buildIntro: ("Show me", .buildFolder)
        case .buildFolder: ("Next", .buildBegin)
        case .buildBegin: ("Next", .install)
        case .buildLaunch: ("Good to know", .buildNote)
        default: ("Got it", .keys)
        }
        return [OnboardingAction(id: "next", label: label, isPrimary: true, effect: .advance(next))]
    }

    private static func installActions(_ facts: OnboardingFacts) -> [OnboardingAction] {
        var actions = [
            OnboardingAction(
                id: "default",
                label: "The default is perfect",
                isPrimary: true,
                effect: .keepInstallLocation
            ),
        ]
        if let external = facts.externalVolume {
            actions.append(OnboardingAction(
                id: "external",
                label: "Use my external drive",
                reply: "Let’s use \(external.name).",
                effect: .useExternal(external)
            ))
        }
        return actions
    }

    private static func keysActions(_ beat: OnboardingBeat, facts: OnboardingFacts) -> [OnboardingAction] {
        if beat == .keysHelp {
            return [
                OnboardingAction(
                    id: "add",
                    label: "Got it, add the file",
                    reply: "Here it is.",
                    isPrimary: true,
                    effect: .pickKeys
                ),
                OnboardingAction(id: "skip", label: "Skip for now", effect: .skipKeys),
            ]
        }
        if facts.detectedKeys != nil {
            return [OnboardingAction(id: "next", label: "Keep going", isPrimary: true, effect: .advance(.player))]
        }
        return [
            OnboardingAction(
                id: "add",
                label: "Add my library key",
                reply: "Here it is.",
                isPrimary: true,
                effect: .pickKeys
            ),
            OnboardingAction(id: "help", label: "Remind me what it is", effect: .showKeysHelp),
            OnboardingAction(id: "skip", label: "Skip for now", effect: .skipKeys),
        ]
    }

    private static func playerActions(_ beat: OnboardingBeat, facts: OnboardingFacts) -> [OnboardingAction] {
        if beat == .playerInstall {
            return [OnboardingAction(id: "next", label: "Keep going", isPrimary: true, effect: .advance(.final))]
        }
        guard !facts.emulatorOffers.isEmpty else {
            return [OnboardingAction(id: "next", label: "Sounds good", isPrimary: true, effect: .advance(.final))]
        }
        let label = facts.emulators.isEmpty ? "Set them up" : "Set up the ones I ticked"
        return [
            OnboardingAction(id: "install", label: label, isPrimary: true, effect: .installEmulators),
            OnboardingAction(id: "later", label: "Not now", effect: .advance(.final)),
        ]
    }
}
