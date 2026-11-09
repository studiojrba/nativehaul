import Foundation

extension LibraryViewModel {
    /// The "Jump Back In" shelf: shown on All Games only, and not while searching. Empty hides it.
    func jumpBackIn(now: Date = .now) -> [Game] {
        guard filter.section == .all, filter.searchText.isEmpty else { return [] }
        return JumpBackIn.games(from: games, now: now)
    }
}
