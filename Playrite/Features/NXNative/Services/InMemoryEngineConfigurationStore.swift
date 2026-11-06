import Foundation

/// Mock ``EngineConfigurationStoring``.
@MainActor
final class InMemoryEngineConfigurationStore: EngineConfigurationStoring {
    private var configuration: EngineConfiguration

    /// Creates the store.
    init(_ configuration: EngineConfiguration = EngineConfiguration()) {
        self.configuration = configuration
    }

    func load() -> EngineConfiguration {
        configuration
    }

    func save(_ configuration: EngineConfiguration) {
        self.configuration = configuration
    }
}
