import Foundation

/// Couch's longer lines (ADR 0058), kept out of the views. Never names the app that runs a game, and never promises a
/// game stays in front.
enum CouchCopy {
    /// The closing wait: "Asking {short} to close, so it can save first…".
    static func closing(_ short: String) -> String {
        "Asking \(short) to close, so it can save first…"
    }

    /// The force-quit offer's unsaved-progress warning (TV plan Q3).
    static func forceQuitWarning(_ short: String) -> String {
        "\(short) hasn't closed yet. Force quit closes it now, and anything since your last save is lost."
    }

    /// The launch phase's line: "Starting {short}".
    static func starting(_ title: String) -> String {
        "Starting \(ShortTitle.make(from: title))"
    }
}
