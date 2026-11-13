import Foundation

extension OnboardingScript {
    /// The emulator beat (notes 5, 12): the real emulators found, then an offer to set up others from their official
    /// sources, or to set some up from scratch with the recommended ones ticked.
    static func player(_ facts: OnboardingFacts) -> [String] {
        var lines = keysOutcomeLine(facts.keysOutcome).map { [$0] } ?? []
        let found = facts.emulators
        let hasOffers = !facts.emulatorOffers.isEmpty
        if found.isEmpty {
            guard hasOffers else {
                return lines + [
                    "Last bit of plumbing: I didn’t find any emulator apps on this Mac yet.",
                    "That’s okay. When a game needs one, I’ll say which, right there.",
                ]
            }
            return lines + [
                "Last bit of plumbing: there are no emulator apps on this Mac yet.",
                "Want me to set some up? I’ve ticked the ones I’d recommend, and I’ll grab each one from its "
                    + "official source.",
            ]
        }
        lines.append("Last bit of plumbing: I found \(playerList(found)) on this Mac.")
        guard hasOffers else {
            return lines + ["I’ll open each game in the right one. You can change that in Settings any time."]
        }
        return lines + ["Want to set up any others now? Tick the ones you’d like and I’ll grab them from their "
            + "official sources."]
    }

    /// While the chosen emulators install.
    static let playerInstall = [
        "On it. Each one shows its progress on the right, and macOS’s verdict on its signature before it goes in.",
    ]

    /// The closing beat (note 6), in nativehaul's voice.
    static let closing = [
        "Great choice.",
        "If you change your mind or want to tweak anything, it’s all in Settings, and you can take this tour again "
            + "from there too.",
        "Happy gaming!",
    ]

    /// "RetroArch, Dolphin and the nxnative engine".
    static func playerList(_ players: [DetectedPlayer]) -> String {
        let names = players.map { $0.kind == .buildEngine ? "the nxnative engine" : $0.name }
        return naturalList(names)
    }

    private static func keysOutcomeLine(_ outcome: KeysOutcome?) -> String? {
        switch outcome {
        case .placed: "Got it, your library key is in place."
        case .alreadyThere: "There was already a library key in that spot, so I kept that one."
        case .skipped: "No problem. Switch builds can wait until you have it."
        case .failed: "I couldn’t copy that file, so let’s leave it for now. You can add it in Settings."
        case nil: nil
        }
    }
}
