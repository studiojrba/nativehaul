import Foundation

/// A game's update badge. It only reports; it never updates a game:
/// - **Switch ports**: compared with a community dataset. nativehaul never downloads game files.
/// - **Emulated ROMs**: static files, so there is never a badge.
enum GameUpdateBadge: Equatable, Sendable {
    /// A newer version of this Switch title exists.
    case switchUpdateAvailable(latest: String)

    /// J.R's copy for Switch ports.
    static let switchUpdateCopy = "An update is available! Please refer to your original source for update files."

    /// Badge text.
    var text: String {
        switch self {
        case .switchUpdateAvailable: Self.switchUpdateCopy
        }
    }
}
