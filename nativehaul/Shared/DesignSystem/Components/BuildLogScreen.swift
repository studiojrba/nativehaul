import Foundation

/// Where a build log lives; its expanded or default height is remembered per screen (note 18).
enum BuildLogScreen: String, Sendable {
    /// The onboarding build tutorial.
    case onboarding
    /// The Builds page.
    case builds
    /// A game's Detail page.
    case detail

    /// The UserDefaults key for this screen's choice (a view preference, not a secret).
    var storageKey: String {
        "nativehaul.buildLog.expanded.\(rawValue)"
    }
}
