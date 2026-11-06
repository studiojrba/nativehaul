import Foundation

/// A game's update badge. Each source updates differently, so the badge only reports — it never updates a game:
/// - **Steam** (Mac or a CrossOver bottle): from the appmanifest. Steam does the updating, the next time it runs.
/// - **Switch ports**: compared with a community dataset. Retriever never downloads game files.
/// - **Emulated ROMs**: static files, so there is never a badge.
enum GameUpdateBadge: Equatable, Sendable {
    /// Steam has an update waiting; launching through Steam installs it.
    case steamUpdatePending
    /// Steam is downloading an update (0…1 when known).
    case steamDownloading(fraction: Double?)
    /// A newer version of this Switch title exists.
    case switchUpdateAvailable(latest: String)

    /// J.R's copy for Switch ports.
    static let switchUpdateCopy = "An update is available! Please refer to your original source for update files."

    /// Badge text.
    var text: String {
        switch self {
        case .steamUpdatePending: "Update pending — Steam will install it when it runs"
        case let .steamDownloading(fraction):
            fraction.map { "Updating — \(Int(($0 * GameUpdateBadge.percent).rounded()))%" } ?? "Updating…"
        case .switchUpdateAvailable: Self.switchUpdateCopy
        }
    }

    private static let percent = 100.0
}
