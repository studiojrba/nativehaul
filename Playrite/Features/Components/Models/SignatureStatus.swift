import Foundation

/// What macOS says about a downloaded app, shown to the user before installing.
enum SignatureStatus: Equatable, Sendable {
    /// Signed with a Developer ID and notarized by Apple.
    case notarized(team: String)
    /// Signed, but Gatekeeper doesn't accept it as notarized.
    case signed(team: String)
    /// Not signed (or ad-hoc signed).
    case unsigned
    /// The signature is broken.
    case invalid(String)

    /// The line shown before installing.
    var summary: String {
        switch self {
        case let .notarized(team): "Signed by \(team), notarized"
        case let .signed(team): "Signed by \(team), not notarized — macOS will ask you to confirm when it first opens"
        case .unsigned: "Unsigned — macOS will ask you to confirm when it first opens"
        case let .invalid(reason): "The signature is broken (\(reason)). Installing isn't recommended."
        }
    }

    /// Whether an opted-in automatic update may install this without asking.
    var allowsUnattendedInstall: Bool {
        if case .notarized = self {
            true
        } else {
            false
        }
    }

    /// The signing team, when signed.
    var team: String? {
        switch self {
        case let .notarized(team), let .signed(team): team
        case .unsigned, .invalid: nil
        }
    }
}
