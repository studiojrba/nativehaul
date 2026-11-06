import Foundation

/// Mock ``ComponentPreferencesStoring``.
@MainActor
final class InMemoryComponentPreferences: ComponentPreferencesStoring {
    var preferences: ComponentPreferences

    /// Creates the store.
    init(_ preferences: ComponentPreferences = ComponentPreferences()) {
        self.preferences = preferences
    }
}
