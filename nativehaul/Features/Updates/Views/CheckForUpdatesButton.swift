import SwiftUI

/// "Check for Updates…", in the app menu and in Settings → Updates. Disabled while a check runs, or when no updater
/// exists (the app failed to start).
struct CheckForUpdatesButton: View {
    /// The updater, if the app started.
    let updater: (any AppUpdating)?

    var body: some View {
        Button("Check for Updates…") { updater?.checkForUpdates() }
            .disabled(!(updater?.canCheckForUpdates ?? false))
    }
}

#Preview {
    CheckForUpdatesButton(updater: MockAppUpdater())
        .padding(DesignTokens.Spacing.lg)
}
