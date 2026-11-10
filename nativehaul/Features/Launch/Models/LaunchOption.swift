import Foundation

/// One user-visible way to launch a game, e.g. "Play" or "Play in RetroArch".
struct LaunchOption: Equatable, Identifiable, Sendable {
    /// Button / menu label.
    let title: String
    /// What runs.
    let target: LaunchTarget
    /// Whether launching through this option records ``PlaytimeSource/macTracked`` sessions.
    let isTracked: Bool

    /// App whose next launch should be credited to this game (emulators run many games from one app).
    var trackedAppPath: String?

    /// Identity for menus.
    var id: String {
        title
    }
}
