import Foundation

/// Works out a game's update badge (see ``GameUpdateBadge``). Read-only.
@MainActor
struct GameUpdateBadgeProvider {
    private let switchVersions: SwitchTitleVersions

    /// Creates the provider.
    init(switchVersions: SwitchTitleVersions) {
        self.switchVersions = switchVersions
    }

    /// The badge for `game`, if any.
    func badge(for game: Game) -> GameUpdateBadge? {
        guard game.platform == .switchPort, let titleID = game.switchTitleID?.uppercased(),
              let built = game.switchVersion,
              let entry = switchVersions.titles[titleID], entry.latestVersion > built
        else { return nil }
        return .switchUpdateAvailable(latest: entry.displayVersion)
    }
}
