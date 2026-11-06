import Foundation

/// Outcome of applying detected Steam installs to the library.
struct SteamProvenanceSummary: Equatable, Sendable {
    /// Installs found in Mac Steam.
    var macInstalls = 0
    /// Installs found in CrossOver bottles.
    var crossOverInstalls = 0
    /// Existing entries without a Steam app that were linked by normalised title.
    var linked = 0
    /// New Steam entries created for installed games not yet in the library.
    var added = 0

    /// One-line description.
    var description: String {
        "Steam installs: \(macInstalls) Mac, \(crossOverInstalls) CrossOver · \(linked) linked, \(added) added."
    }
}
