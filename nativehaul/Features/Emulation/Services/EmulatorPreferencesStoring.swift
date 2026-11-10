import Foundation

/// Per-system emulator overrides (the optional tinker setting). Live: ``UserDefaultsEmulatorPreferences``; mock:
/// ``InMemoryEmulatorPreferences``.
@MainActor
protocol EmulatorPreferencesStoring: AnyObject {
    /// Overridden profile ID for `system`, or `nil` for the default.
    func profileID(for system: EmulatedSystem) -> String?
    /// Sets or clears an override.
    func setProfileID(_ id: String?, for system: EmulatedSystem)
}
