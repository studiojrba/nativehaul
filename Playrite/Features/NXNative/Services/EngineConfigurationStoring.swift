import Foundation

/// Persists ``EngineConfiguration``. Live: ``UserDefaultsEngineConfigurationStore``.
@MainActor
protocol EngineConfigurationStoring: AnyObject {
    /// Loads (defaults when none saved).
    func load() -> EngineConfiguration
    /// Saves.
    func save(_ configuration: EngineConfiguration)
}
