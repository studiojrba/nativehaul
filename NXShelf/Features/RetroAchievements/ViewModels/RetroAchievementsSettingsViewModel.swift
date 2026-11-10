import Foundation
import Observation

/// Settings → RetroAchievements (ADR 0047): the optional username and web API key. Stored values are never read back
/// into the UI. Without them the feature is simply absent.
@MainActor
@Observable
final class RetroAchievementsSettingsViewModel {
    /// Username being typed.
    var usernameInput = ""
    /// Web API key being typed.
    var apiKeyInput = ""
    /// Whether both are in the Keychain.
    private(set) var hasCredentials = false
    /// Result of the last action.
    private(set) var statusMessage: String?
    /// `true` when the last action failed.
    private(set) var isError = false

    private let store: any RetroAchievementsCredentialStoring

    /// Creates the view model. The Keychain is read off the main thread (ADR 0044) by ``refresh()``.
    init(store: any RetroAchievementsCredentialStoring) {
        self.store = store
    }

    /// Whether both fields have something to save.
    var canSave: Bool {
        !usernameInput.trimmingCharacters(in: .whitespaces).isEmpty
            && !apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// Reads whether credentials are stored, off the main thread.
    func refresh() async {
        let store = store
        hasCredentials = await Task.detached { store.credentials() != nil }.value
    }

    /// Saves both values and clears the fields.
    func save() {
        guard canSave else { return }
        perform("Saved. Your RetroAchievements key is stored only in your Keychain.") {
            try store.save(username: usernameInput, apiKey: apiKeyInput)
            usernameInput = ""
            apiKeyInput = ""
        }
    }

    /// Removes both values.
    func remove() {
        perform("RetroAchievements credentials removed from Keychain.") { try store.remove() }
    }

    private func perform(_ success: String, _ work: () throws -> Void) {
        do {
            try work()
            statusMessage = success
            isError = false
        } catch {
            statusMessage = error.localizedDescription
            isError = true
        }
        Task { await refresh() }
    }
}
