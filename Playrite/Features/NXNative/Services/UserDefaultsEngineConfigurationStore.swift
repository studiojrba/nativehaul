import Foundation

/// Live ``EngineConfigurationStoring`` (JSON in `UserDefaults`). Contains paths only — never keys or game data.
@MainActor
final class UserDefaultsEngineConfigurationStore: EngineConfigurationStoring {
    private static let key = "nxnative.configuration"
    private let defaults: UserDefaults

    /// Creates the store.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> EngineConfiguration {
        guard let data = defaults.data(forKey: Self.key),
              let configuration = try? JSONDecoder().decode(EngineConfiguration.self, from: data)
        else { return EngineConfiguration() }
        return configuration
    }

    func save(_ configuration: EngineConfiguration) {
        defaults.set(try? JSONEncoder().encode(configuration), forKey: Self.key)
    }
}
