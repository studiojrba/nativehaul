import Foundation
import Observation

/// Settings → Emulators: which emulator runs each system (defaults work as-is; overrides are optional) and whether
/// each emulator app is installed.
@MainActor
@Observable
final class EmulatorSettingsViewModel {
    /// One system row.
    struct SystemRow: Identifiable, Equatable {
        /// The system.
        let system: EmulatedSystem
        /// Emulator in use.
        let profile: EmulatorProfile
        /// Choices for this system.
        let choices: [EmulatorProfile]
        /// Whether the emulator app is installed.
        let isInstalled: Bool

        /// Stable identity.
        var id: String {
            system.id
        }
    }

    private let router: EmulatorRouter
    private var revision = 0

    /// Creates the view model.
    init(router: EmulatorRouter) {
        self.router = router
    }

    /// Every system with its emulator.
    var rows: [SystemRow] {
        _ = revision
        return EmulatedSystem.allCases.map { system in
            let profile = router.profile(for: system)
            return SystemRow(
                system: system,
                profile: profile,
                choices: EmulatorCatalog.profiles(for: system),
                isInstalled: router.appPath(for: profile) != nil
            )
        }
    }

    /// Emulators found on this Mac.
    var installedEmulators: [EmulatorProfile] {
        _ = revision
        return EmulatorCatalog.profiles.filter { router.appPath(for: $0) != nil }
    }

    /// Picks an emulator for a system (the default when `profile` is the system's default).
    func choose(_ profile: EmulatorProfile, for system: EmulatedSystem) {
        let isDefault = profile.id == EmulatorCatalog.defaultProfile(for: system).id
        router.setProfile(isDefault ? nil : profile, for: system)
        revision += 1
    }

    /// Re-checks installed apps.
    func refresh() {
        revision += 1
    }
}
