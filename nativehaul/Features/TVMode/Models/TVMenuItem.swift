import Foundation

/// A row in the TV Start/Options menu (ADR 0052).
enum TVMenuItem: Equatable, Sendable, Identifiable {
    /// TV options: switches between shelves and grid.
    case layout(TVLayout)
    /// Shows the current audio output; changing it happens in macOS (Control Center), never silently here.
    case audioOutput(String?)
    /// Sleep, Restart or Shut Down, after a confirmation.
    case power(TVPowerAction)
    /// Leaves TV mode for the desktop window.
    case exitTVMode

    /// Stable identity.
    var id: String {
        switch self {
        case .layout: "layout"
        case .audioOutput: "audio"
        case let .power(action): action.title
        case .exitTVMode: "exit"
        }
    }

    /// Row title.
    var title: String {
        switch self {
        case let .layout(layout): "Layout: \(layout.displayName)"
        case let .audioOutput(name): "Audio: \(name ?? "Unknown")"
        case let .power(action): action.title
        case .exitTVMode: "Exit TV Mode"
        }
    }

    /// A note under the row, if any.
    var note: String? {
        switch self {
        case .audioOutput: "Change the output in Control Center or System Settings → Sound."
        case .layout, .power, .exitTVMode: nil
        }
    }
}
