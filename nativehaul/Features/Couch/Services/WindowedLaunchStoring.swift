import Foundation

/// The per-game "Open windowed" override for couch launches (TV plan Q1 safety valve, ADR 0058), set from the desktop
/// Manage sheet. Kept outside the SwiftData store (a set of game IDs), so it needs no schema change. Live:
/// ``UserDefaultsWindowedLaunchStore``; mock: ``InMemoryWindowedLaunchStore``.
@MainActor
protocol WindowedLaunchStoring: AnyObject {
    /// Whether couch opens `gameID` in a window instead of full screen.
    func opensWindowed(_ gameID: UUID) -> Bool
    /// Sets the override for `gameID`.
    func setOpensWindowed(_ isWindowed: Bool, for gameID: UUID)
}
