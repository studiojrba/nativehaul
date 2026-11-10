import Foundation

/// A view's games split by ``InstallState`` for the Installed filter (ADR 0036). Unknown games are kept apart and
/// flagged, never silently dropped.
@MainActor
struct InstalledSplit {
    /// Games with a present, launchable install.
    let installed: [Game]
    /// Games no source can report on.
    let unknown: [Game]
    /// How many games had an install that's gone.
    let notInstalledCount: Int

    /// Splits `games`, keeping their order.
    static func make(
        _ games: [Game],
        state: (Game) -> InstallState = { InstallState.of($0) }
    ) -> InstalledSplit {
        var installed: [Game] = []
        var unknown: [Game] = []
        var notInstalled = 0
        for game in games {
            switch state(game) {
            case .installed: installed.append(game)
            case .unknown: unknown.append(game)
            case .notInstalled: notInstalled += 1
            }
        }
        return InstalledSplit(installed: installed, unknown: unknown, notInstalledCount: notInstalled)
    }

    /// The count line: "3 installed · 2 can't tell · 1 not installed" (zero parts after the first are left out).
    var summary: String {
        var parts = ["\(installed.count) installed"]
        if !unknown.isEmpty {
            parts.append("\(unknown.count) can't tell")
        }
        if notInstalledCount > 0 {
            parts.append("\(notInstalledCount) not installed")
        }
        return parts.joined(separator: " · ")
    }
}
