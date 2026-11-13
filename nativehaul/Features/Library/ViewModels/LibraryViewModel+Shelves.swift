import Foundation

extension LibraryViewModel {
    /// The current view (section and search) split by install state, for the Installed filter (ADR 0036).
    var installedSplit: InstalledSplit {
        InstalledSplit.make(filter.apply(to: games))
    }

    /// The Library page's games: the menu bar's section and Installed filters applied, in the chosen sort order.
    var shelfGames: [Game] {
        sort.apply(to: visibleGames)
    }

    /// `true` when a menu bar filter narrows the Library page.
    var isFiltered: Bool {
        filter.section != .all || filter.installedOnly
    }

    /// What the active filters show, for the Library page's filter chip ("Playing · Installed only").
    var filterDescription: String {
        var parts: [String] = []
        if filter.section != .all {
            parts.append(filter.section.title)
        }
        if filter.installedOnly {
            parts.append("Installed only")
        }
        return parts.joined(separator: " · ")
    }

    /// Clears the menu bar filters.
    func clearFilters() {
        filter.section = .all
        filter.installedOnly = false
    }
}
