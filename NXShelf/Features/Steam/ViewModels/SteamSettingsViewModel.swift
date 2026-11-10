import Foundation
import Observation

/// Settings → Steam. The stored key is never read back into the UI; only its presence is shown.
@MainActor
@Observable
final class SteamSettingsViewModel {
    /// Key being typed (cleared after saving).
    var apiKeyInput = ""
    /// SteamID64 being edited.
    var steamIDInput: String
    /// Result of the last action.
    private(set) var statusMessage: String?
    /// `true` when the last action failed.
    private(set) var isError = false
    /// Whether a key is in the Keychain.
    private(set) var hasAPIKey: Bool
    /// Called after a successful save or key removal.
    var onSaved: (@MainActor () -> Void)?

    private let account: any SteamAccountStoring

    /// Creates the view model.
    init(account: any SteamAccountStoring) {
        self.account = account
        steamIDInput = account.steamID?.rawValue ?? ""
        hasAPIKey = account.hasAPIKey
    }

    /// `true` when the SteamID field is empty or valid.
    var isSteamIDValid: Bool {
        steamIDInput.trimmingCharacters(in: .whitespaces).isEmpty || SteamID(steamIDInput) != nil
    }

    /// Saves the key (if typed) to the Keychain and the SteamID to defaults.
    func save() {
        guard isSteamIDValid else {
            report("SteamID64 must be 17 digits starting with 7656119.", isError: true)
            return
        }
        do {
            if !apiKeyInput.trimmingCharacters(in: .whitespaces).isEmpty {
                try account.saveAPIKey(apiKeyInput)
                apiKeyInput = ""
            }
            account.saveSteamID(SteamID(steamIDInput))
            hasAPIKey = account.hasAPIKey
            report("Saved. The API key is stored only in your Keychain.", isError: false)
            onSaved?()
        } catch {
            report(error.localizedDescription, isError: true)
        }
    }

    /// Deletes the key from the Keychain.
    func removeAPIKey() {
        do {
            try account.removeAPIKey()
            hasAPIKey = account.hasAPIKey
            report("API key removed from Keychain.", isError: false)
            onSaved?()
        } catch {
            report(error.localizedDescription, isError: true)
        }
    }

    private func report(_ message: String, isError: Bool) {
        statusMessage = message
        self.isError = isError
    }
}
