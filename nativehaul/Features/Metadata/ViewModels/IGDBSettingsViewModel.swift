import Foundation
import Observation

/// Settings → API keys → IGDB (ADR 0038): the optional Twitch Client ID and secret. Stored values are never read back
/// into the UI. Without them IGDB is simply not used; nothing asks for them anywhere else.
@MainActor
@Observable
final class IGDBSettingsViewModel {
    /// Client ID being typed.
    var clientIDInput = ""
    /// Client secret being typed.
    var clientSecretInput = ""
    /// Whether both credentials are in the Keychain (``refresh()`` reads it off the main thread, ADR 0044).
    private(set) var hasCredentials = false
    /// Result of the last action.
    private(set) var statusMessage: String?
    /// `true` when the last action failed.
    private(set) var isError = false

    private let store: any IGDBCredentialStoring

    /// Creates the view model.
    init(store: any IGDBCredentialStoring) {
        self.store = store
    }

    /// Reads whether credentials are stored, off the main thread.
    func refresh() async {
        let store = store
        hasCredentials = await Task.detached { store.credentials() != nil }.value
    }

    /// Whether both fields have something to save.
    var canSave: Bool {
        !clientIDInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !clientSecretInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Saves both credentials to the Keychain and clears the fields.
    func save() {
        guard canSave else { return }
        perform("Saved. IGDB credentials are stored only in your Keychain.", isStored: true) {
            try store.save(clientID: clientIDInput, clientSecret: clientSecretInput)
            clientIDInput = ""
            clientSecretInput = ""
        }
    }

    /// Removes both credentials.
    func remove() {
        perform("IGDB credentials removed from Keychain.", isStored: false) { try store.remove() }
    }

    private func perform(_ success: String, isStored: Bool, _ work: () throws -> Void) {
        do {
            try work()
            hasCredentials = isStored
            statusMessage = success
            isError = false
        } catch {
            statusMessage = error.localizedDescription
            isError = true
        }
    }
}
