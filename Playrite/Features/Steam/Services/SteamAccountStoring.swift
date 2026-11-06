import Foundation

/// Manages the Steam account configuration: API key (Keychain only) and SteamID64.
@MainActor
protocol SteamAccountStoring: AnyObject {
    /// `true` when a key is present in the Keychain.
    var hasAPIKey: Bool { get }
    /// The configured SteamID64, if valid.
    var steamID: SteamID? { get }
    /// Saves the key to the Keychain.
    func saveAPIKey(_ key: String) throws
    /// Deletes the key from the Keychain.
    func removeAPIKey() throws
    /// Saves (or clears with `nil`) the SteamID64.
    func saveSteamID(_ steamID: SteamID?)
    /// Builds credentials or throws ``SteamError/missingAPIKey`` / ``SteamError/missingSteamID``.
    func credentials() throws -> SteamCredentials
}
