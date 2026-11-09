import Foundation

extension LibraryViewModel {
    /// The current view (section and search) split by install state, for the Installed filter (ADR 0036).
    var installedSplit: InstalledSplit {
        InstalledSplit.make(filter.apply(to: games))
    }

    /// The "Jump Back In" shelf: shown on All Games only, and not while searching; with the Installed filter on, only
    /// installed games. Empty hides it.
    func jumpBackIn(now: Date = .now) -> [Game] {
        guard filter.section == .all, filter.searchText.isEmpty else { return [] }
        let shelf = JumpBackIn.games(from: games, now: now)
        return filter.installedOnly ? InstalledSplit.make(shelf).installed : shelf
    }
}
