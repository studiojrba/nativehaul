import Foundation

/// In-memory ``TVModePreferencesStoring`` for previews and tests.
@MainActor
final class InMemoryTVModePreferences: TVModePreferencesStoring {
    var preferences: TVModePreferences

    /// Creates the store.
    init(_ preferences: TVModePreferences = TVModePreferences()) {
        self.preferences = preferences
    }
}
