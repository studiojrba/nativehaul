import Foundation

/// One step of the guided tour (ADR 0040, the Kriss way): Retriever says a few short lines, one idea at a time, in
/// the part of the app the step is about, with the relevant control highlighted. Every step can be skipped.
enum GuideStep: String, Codable, CaseIterable, Sendable {
    case welcome
    case library
    case gamePage
    case builds
    case steam
    case farewell

    /// What Retriever says, one line at a time.
    var lines: [String] {
        switch self {
        case .welcome:
            [
                "Hi! I'm Retriever.",
                "I keep all your games in one cozy place: Steam, Switch ports, emulators, the lot.",
                "Let me show you around. It takes a minute, and you can skip anything.",
            ]
        case .library:
            [
                "This is your library.",
                "Show me the folders where your games live, and I'll find them for you.",
                "Pick a folder now, or skip. You can always do it later from the Library File menu.",
            ]
        case .gamePage:
            [
                "Every game gets its own page, like this one.",
                "Drag the case to turn it over. When you're ready, press Play Now.",
                "I'll quietly keep track of your time while you play.",
            ]
        case .builds:
            [
                "This is Builds.",
                "If you own Switch games, I can help turn your own copies into Mac apps with nxnative.",
                "Add Job starts one. Nothing happens unless you ask.",
            ]
        case .steam:
            [
                "Last stop: Steam, over in Settings.",
                "Sign in and I'll bring in your Steam library, playtime and achievements.",
                "Anything you paste here stays in your Keychain.",
            ]
        case .farewell:
            [
                "That's the tour!",
                "If you ever want it again, it's in Settings → General.",
                "Have fun out there.",
            ]
        }
    }

    /// Where the step happens.
    var destination: GuideDestination {
        switch self {
        case .welcome, .farewell: .home
        case .library: .library
        case .gamePage: .gamePage
        case .builds: .builds
        case .steam: .steamSettings
        }
    }

    /// The control it highlights, if any.
    var hotspot: GuideHotspot? {
        switch self {
        case .welcome, .farewell: nil
        case .library: .gameFolders
        case .gamePage: .playNow
        case .builds: .addBuildJob
        case .steam: .steamSignIn
        }
    }

    /// The main button's title.
    var primaryTitle: String {
        switch self {
        case .welcome: "Show me around"
        case .library: "Choose game folders…"
        case .gamePage, .builds, .steam: "Next"
        case .farewell: "Let's play"
        }
    }

    /// The step after this one, or `nil` after the last.
    var next: GuideStep? {
        let all = Self.allCases
        guard let index = all.firstIndex(of: self), index + 1 < all.count else { return nil }
        return all[index + 1]
    }
}
