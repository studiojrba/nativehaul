import Observation
import SwiftUI

/// The app's Light/Dark appearance (spec §1.4, ADR 0054): Dark on first launch, the saved choice afterwards. A change
/// applies instantly to every window and is remembered. Lives in ``AppEnvironment``; the sidebar toggle and
/// Settings → Appearance both drive it.
@MainActor
@Observable
final class AppearanceController {
    /// The active choice. Setting it saves and applies at once.
    var preference: AppearancePreference {
        didSet {
            guard preference != oldValue else { return }
            store.save(preference)
            applier.apply(preference)
        }
    }

    @ObservationIgnored private let store: any AppearanceStoring
    @ObservationIgnored private let applier: any AppearanceApplying

    /// Creates the controller and applies the starting appearance.
    init(store: any AppearanceStoring, applier: any AppearanceApplying) {
        self.store = store
        self.applier = applier
        preference = Self.startingPreference(from: store)
        applier.apply(preference)
    }

    /// The colour scheme for `.preferredColorScheme`.
    var colorScheme: ColorScheme {
        preference.colorScheme
    }

    /// Switches between Light and Dark.
    func toggle() {
        preference = preference.toggled
    }

    /// The saved choice, or Dark on first launch.
    static func startingPreference(from store: any AppearanceStoring) -> AppearancePreference {
        store.load() ?? .firstLaunchDefault
    }

    /// An in-memory controller for previews.
    static var preview: AppearanceController {
        AppearanceController(store: InMemoryAppearanceStore(), applier: RecordingAppearanceApplier())
    }
}
