import Foundation

/// In-memory ``ModePreferenceStoring`` for previews and tests.
@MainActor
final class InMemoryModePreferenceStore: ModePreferenceStoring {
    var defaultMode: AppMode
    var isRumbleEnabled: Bool

    /// Creates the store with the shipped defaults (desktop, rumble on) unless told otherwise.
    init(defaultMode: AppMode = .desktop, isRumbleEnabled: Bool = true) {
        self.defaultMode = defaultMode
        self.isRumbleEnabled = isRumbleEnabled
    }
}
