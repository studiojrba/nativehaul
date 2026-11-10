import Foundation

/// Managed components (emulator apps): status, one-click install, update checks and opt-in auto-update.
/// Live: ``ComponentUpdateService``; mock: ``MockComponentUpdater``.
@MainActor
protocol ComponentUpdating: AnyObject {
    /// The catalog.
    var catalog: ComponentCatalog { get }
    /// Current settings.
    var preferences: ComponentPreferences { get }
    /// A newer NX Shelf release tag, when one is known (notify-only).
    var appUpdate: String? { get }
    /// Status of a component, or `nil` if it isn't in the catalog.
    func status(for id: String) -> ComponentStatus?
    /// Checks official sources — at most once a day unless `force`.
    func checkForUpdates(force: Bool) async
    /// Downloads, verifies and unpacks; stops at `awaitingConfirmation` with the signature status.
    func prepareInstall(_ id: String, onStage: @escaping @MainActor (ComponentInstallStage) -> Void) async
    /// Installs what `prepareInstall` staged.
    func confirmInstall(_ id: String, onStage: @escaping @MainActor (ComponentInstallStage) -> Void) async
    /// Lets NX Shelf manage a copy the user installed themselves (asked first, never assumed).
    func takeOver(_ id: String)
    /// "Automatically update components" (off by default).
    func setAutoUpdateAll(_ isOn: Bool)
    /// Per-component opt-in.
    func setAutoUpdate(_ id: String, _ isOn: Bool)
    /// Installs opted-in updates that macOS reports as notarized by the same team; everything else waits for a click.
    func runAutomaticUpdates() async
}
