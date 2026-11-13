import Foundation

/// Tools that live outside the 0.1.0 nav island, opened from the Go menu as a sheet over the main window so nothing is
/// lost (a sheet rather than a window: nativehaul never brings windows forward by itself, ADR 0030).
enum ToolSheet: String, CaseIterable, Hashable, Identifiable, Sendable {
    case series
    case collections
    case stats
    case tracking

    /// Stable identity.
    var id: String {
        rawValue
    }

    /// Sheet and menu title.
    var title: String {
        switch self {
        case .series: "Series"
        case .collections: "Collections"
        case .stats: "Stats & Badges"
        case .tracking: "Playtime Tracking"
        }
    }

    /// The menu item's key equivalent, used with ⌥⌘.
    var keyEquivalent: Character {
        switch self {
        case .series: "1"
        case .collections: "2"
        case .stats: "3"
        case .tracking: "4"
        }
    }
}
