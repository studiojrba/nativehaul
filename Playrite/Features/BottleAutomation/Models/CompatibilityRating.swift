import Foundation

/// How well a game runs in CrossOver, per its recipe.
enum CompatibilityRating: String, Codable, Sendable {
    /// Runs well with the recipe.
    case works
    /// Runs, with caveats in the notes.
    case mostlyWorks
    /// No known result yet.
    case untested
    /// Anti-cheat refuses to run under CrossOver.
    case antiCheatBlocked
    /// Known not to work.
    case broken

    /// Whether Retriever refuses to offer a download.
    var blocksInstall: Bool {
        self == .antiCheatBlocked || self == .broken
    }

    /// User-facing name.
    var displayName: String {
        switch self {
        case .works: "Works"
        case .mostlyWorks: "Mostly works"
        case .untested: "Untested"
        case .antiCheatBlocked: "Blocked by anti-cheat"
        case .broken: "Known not to work"
        }
    }
}
