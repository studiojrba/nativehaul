import Foundation

/// Decides which bottle a game installs into.
///
/// Slice 1 ships ``PerGameBottlePlanner`` only: one bottle per game, so each recipe's settings apply to one game.
/// A shared-bottle mode would be another implementation of this protocol.
protocol BottlePlanning: Sendable {
    /// The bottle for a new install of `title`.
    func plan(forTitle title: String) -> BottlePlan
}
