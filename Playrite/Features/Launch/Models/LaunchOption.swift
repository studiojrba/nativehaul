import Foundation

/// One user-visible way to launch a game, e.g. "Steam (Mac)".
struct LaunchOption: Equatable, Identifiable, Sendable {
    /// Button / menu label.
    let title: String
    /// What runs.
    let target: LaunchTarget
    /// Whether launching through this option records ``PlaytimeSource/macTracked`` sessions.
    let isTracked: Bool

    /// Identity for menus.
    var id: String {
        title
    }
}
