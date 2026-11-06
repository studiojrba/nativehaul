import Foundation
import Observation

/// Settings → NXNative.
@MainActor
@Observable
final class NXNativeSettingsViewModel {
    /// Editable configuration.
    var configuration: EngineConfiguration
    /// Confirmation of the last save.
    private(set) var statusMessage: String?

    private let store: any EngineConfigurationStoring

    /// Creates the view model.
    init(store: any EngineConfigurationStoring) {
        self.store = store
        configuration = store.load()
    }

    /// `true` when the hidden library folder name starts with a dot.
    var isLibraryNameValid: Bool {
        configuration.hiddenLibraryFolderName.hasPrefix(".") && configuration.hiddenLibraryFolderName.count > 1
    }

    /// Sets the engine path from a user-chosen file.
    func setEngine(_ url: URL) {
        configuration.enginePath = url.path
    }

    /// Saves the configuration.
    func save() {
        guard isLibraryNameValid else {
            statusMessage = "The library folder name must start with a dot."
            return
        }
        store.save(configuration)
        statusMessage = "Saved."
    }
}
