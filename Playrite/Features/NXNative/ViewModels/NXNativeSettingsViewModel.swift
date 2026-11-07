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
    private let locator: NXNativeLocator

    /// Creates the view model.
    init(store: any EngineConfigurationStoring, locator: NXNativeLocator) {
        self.store = store
        self.locator = locator
        configuration = store.load()
    }

    /// The engine shown in Settings: the override, or what was detected.
    var engineDescription: String {
        if configuration.hasEngineOverride {
            return "\(configuration.enginePath) (your choice)"
        }
        return locator.detectedEngine().map { "\($0) (found automatically)" } ?? "Not found on this Mac"
    }

    /// The `prod.keys` shown in Settings: the override, or what was detected.
    var keysDescription: String {
        if let path = configuration.keysPath {
            return "\(path) (your choice)"
        }
        return locator.detectedKeys().map { "\($0) (found automatically)" }
            ?? "Not found — you'll be asked for it when you build"
    }

    /// Drops the engine override so the detected engine is used.
    func useDetectedEngine() {
        configuration.enginePath = ""
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
