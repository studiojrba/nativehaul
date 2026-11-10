import Foundation

/// A problem to explain in the Steam setup screen.
enum SteamSetupNotice: Equatable, Sendable {
    /// Steam hides the game details on this profile, so nothing can be synced.
    case privateGameDetails
    /// Steam didn't accept the pasted key.
    case keyRejected
    /// Anything else, already phrased for the user.
    case message(String)
}
