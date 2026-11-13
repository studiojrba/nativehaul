import AppKit

/// Work that must happen before the first window draws (ADR 0054): the bundled fonts are registered and the saved
/// appearance (Dark on first launch) is applied, so there is never a flash of the other mode.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_: Notification) {
        _ = BundledFonts.isRegistered
        let preference = AppearanceController.startingPreference(from: UserDefaultsAppearanceStore())
        ApplicationAppearanceApplier().apply(preference)
    }
}
