import Foundation
import Observation

/// Settings → TV Mode state.
@MainActor
@Observable
final class TVModeSettingsViewModel {
    private let preferences: any TVModePreferencesStoring

    /// Creates the view model.
    init(preferences: any TVModePreferencesStoring) {
        self.preferences = preferences
    }

    /// Library layout in TV mode.
    var layout: TVLayout {
        get {
            access(keyPath: \.layout)
            return preferences.preferences.layout
        }
        set {
            withMutation(keyPath: \.layout) { preferences.preferences.layout = newValue }
        }
    }
}
