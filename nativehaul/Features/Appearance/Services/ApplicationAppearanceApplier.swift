import AppKit

/// Live ``AppearanceApplying``: sets `NSApp.appearance`, which every window and dynamic colour follows.
@MainActor
final class ApplicationAppearanceApplier: AppearanceApplying {
    /// Creates the applier.
    init() {}

    func apply(_ preference: AppearancePreference) {
        NSApplication.shared.appearance = NSAppearance(named: preference.appearanceName)
    }
}
