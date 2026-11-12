import Foundation

/// How TV mode lays out the library (ADR 0052): horizontal shelves by default, or one shelf as a grid.
enum TVLayout: String, Codable, CaseIterable, Identifiable, Sendable {
    /// One horizontal row per shelf, stacked.
    case shelf
    /// The current shelf as a grid.
    case grid

    /// Stable identity for pickers.
    var id: String {
        rawValue
    }

    /// Name shown in settings and the TV menu.
    var displayName: String {
        switch self {
        case .shelf: "Shelves"
        case .grid: "Grid"
        }
    }

    /// The other layout.
    var toggled: TVLayout {
        self == .shelf ? .grid : .shelf
    }
}
