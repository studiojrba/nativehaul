import Foundation

/// The explicit Steam connection states shown in Settings → Steam and the Steam screen.
enum SteamSetupStage: Equatable, Sendable {
    /// No Steam account linked.
    case signedOut
    /// Signed in, but no API key yet — syncing is not possible until one is added.
    case keyNeeded
    /// Signed in with a key: ready to sync.
    case readyToSync
}
