import Foundation

/// A real control a guide step highlights (Kriss-hotspot style). Using it moves the tour on.
enum GuideHotspot: String, Sendable {
    /// The library's Library File menu (game folders, scanning).
    case gameFolders
    /// Play Now on a game page.
    case playNow
    /// Add Job on the Builds page.
    case addBuildJob
    /// Sign in through Steam, in Settings.
    case steamSignIn
}
