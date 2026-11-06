import Foundation

/// Mock ``EmulatorPreferencesStoring``.
@MainActor
final class InMemoryEmulatorPreferences: EmulatorPreferencesStoring {
    private var overrides: [EmulatedSystem: String] = [:]

    /// Creates an empty store.
    init() {}

    func profileID(for system: EmulatedSystem) -> String? {
        overrides[system]
    }

    func setProfileID(_ id: String?, for system: EmulatedSystem) {
        overrides[system] = id
    }
}
