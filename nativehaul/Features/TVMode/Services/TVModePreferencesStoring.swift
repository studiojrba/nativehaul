import Foundation

/// Stores ``TVModePreferences``. Live: ``UserDefaultsTVModePreferences``; mock: ``InMemoryTVModePreferences``.
@MainActor
protocol TVModePreferencesStoring: AnyObject {
    /// Current preferences.
    var preferences: TVModePreferences { get set }
}
