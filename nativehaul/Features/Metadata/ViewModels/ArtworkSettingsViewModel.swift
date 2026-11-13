import Foundation
import Observation

/// Settings → API keys → SteamGridDB: the optional key. The stored key is never read back into the UI, and whether one
/// is stored is read off the main thread (ADR 0044).
@MainActor
@Observable
final class ArtworkSettingsViewModel {
    /// Key being typed (cleared after saving).
    var keyInput = ""
    /// Whether a key is in the Keychain (``refresh()`` reads it).
    private(set) var hasKey = false
    /// Result of the last action.
    private(set) var statusMessage: String?
    /// `true` when the last action failed.
    private(set) var isError = false

    private let store: any SteamGridDBKeyStoring

    /// Creates the view model.
    init(store: any SteamGridDBKeyStoring) {
        self.store = store
    }

    /// Whether the Save button does anything: there is something typed.
    var canSave: Bool {
        !keyInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Reads whether a key is stored, off the main thread.
    func refresh() async {
        hasKey = await store.hasKeyOffMain()
    }

    /// Saves the typed key to the Keychain.
    func save() {
        guard canSave else { return }
        perform("Saved. The SteamGridDB key is stored only in your Keychain.", isStored: true) {
            try store.saveKey(keyInput)
            keyInput = ""
        }
    }

    /// Removes the key.
    func removeKey() {
        perform("SteamGridDB key removed from Keychain.", isStored: false) { try store.removeKey() }
    }

    private func perform(_ success: String, isStored: Bool, _ work: () throws -> Void) {
        do {
            try work()
            hasKey = isStored
            statusMessage = success
            isError = false
        } catch {
            statusMessage = error.localizedDescription
            isError = true
        }
    }
}
