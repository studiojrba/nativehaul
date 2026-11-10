import Foundation

/// A component's state for the Updates list and emulator rows (the badge).
enum ComponentStatus: Equatable, Sendable {
    /// Not on this Mac; one click installs it.
    case notInstalled
    /// Installed and current (or no newer version known).
    case upToDate(version: String?)
    /// A newer official build exists. `isManaged` is false for copies the user installed themselves, which
    /// nativehaul only offers to take over.
    case updateAvailable(current: String?, latest: String, isManaged: Bool)

    /// Badge text, if any.
    var badge: String? {
        switch self {
        case .notInstalled: "Install"
        case .updateAvailable: "Update available"
        case .upToDate: nil
        }
    }
}
