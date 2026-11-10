import SwiftUI

/// Adds "Check for Updates…" under "About nativehaul" in the app menu.
struct CheckForUpdatesCommands: Commands {
    /// The updater, if the app started.
    let updater: (any AppUpdating)?

    var body: some Commands {
        CommandGroup(after: .appInfo) {
            CheckForUpdatesButton(updater: updater)
        }
    }
}
