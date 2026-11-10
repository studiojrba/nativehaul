import Foundation
import Observation

/// Settings → Artwork: the optional SteamGridDB key. The stored key is never read back into the UI.
@MainActor
@Observable
final class ArtworkSettingsViewModel {
    /// Key being typed (cleared after saving).
    var keyInput = ""
    /// Whether a key is in the Keychain.
    private(set) var hasKey: Bool
    /// Result of the last action.
    private(set) var statusMessage: String?
    /// `true` when the last action failed.
    private(set) var isError = false

    private let store: any SteamGridDBKeyStoring

    /// Creates the view model.
    init(store: any SteamGridDBKeyStoring) {
        self.store = store
        hasKey = store.hasKey
    }

    /// Saves the typed key to the Keychain.
    func save() {
        guard !keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        perform("Saved. The SteamGridDB key is stored only in your Keychain.") {
            try store.saveKey(keyInput)
            keyInput = ""
        }
    }

    /// Removes the key.
    func removeKey() {
        perform("SteamGridDB key removed from Keychain.") { try store.removeKey() }
    }

    private func perform(_ success: String, _ work: () throws -> Void) {
        do {
            try work()
            hasKey = store.hasKey
            statusMessage = success
            isError = false
        } catch {
            statusMessage = error.localizedDescription
            isError = true
        }
    }
}
