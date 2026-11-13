import Foundation

/// The badge on a Library cover when a game isn't simply ready (spec §3.2). Only from real state: a build job in
/// progress for the game's title, or a newer version of a built port.
enum LibraryBuildBadge: Equatable, Sendable {
    /// A build for this game's title is queued or running.
    case building
    /// A newer version than the built one exists.
    case updateReady

    /// The pill's label.
    var label: String {
        switch self {
        case .building: "Building…"
        case .updateReady: "Update ready"
        }
    }

    /// The badge for `game`, given the title IDs with a build in progress and whether an update is known.
    static func badge(for game: Game, buildingTitleIDs: Set<String>, hasUpdate: Bool) -> LibraryBuildBadge? {
        if let titleID = game.switchTitleID?.uppercased(), buildingTitleIDs.contains(titleID) {
            return .building
        }
        return hasUpdate ? .updateReady : nil
    }
}
