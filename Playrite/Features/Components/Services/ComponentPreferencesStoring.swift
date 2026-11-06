import Foundation

/// Stores ``ComponentPreferences``. Live: ``UserDefaultsComponentPreferences``; mock: ``InMemoryComponentPreferences``.
@MainActor
protocol ComponentPreferencesStoring: AnyObject {
    /// Current preferences.
    var preferences: ComponentPreferences { get set }
}
