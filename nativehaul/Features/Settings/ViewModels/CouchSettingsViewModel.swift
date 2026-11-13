import Foundation
import Observation

/// Settings → Couch mode (spec §3.5): which mode nativehaul opens in, and controller rumble. Both persist through
/// ``ModePreferenceStoring``; couch mode reads them at launch.
@MainActor
@Observable
final class CouchSettingsViewModel {
    /// "Open in": Desktop or Couch.
    var defaultMode: AppMode {
        didSet { store.defaultMode = defaultMode }
    }

    /// "Controller rumble".
    var isRumbleEnabled: Bool {
        didSet { store.isRumbleEnabled = isRumbleEnabled }
    }

    @ObservationIgnored private let store: any ModePreferenceStoring

    /// Creates the view model from the saved choices.
    init(store: any ModePreferenceStoring) {
        self.store = store
        defaultMode = store.defaultMode
        isRumbleEnabled = store.isRumbleEnabled
    }
}
