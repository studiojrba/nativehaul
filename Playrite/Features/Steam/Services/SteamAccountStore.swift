import Foundation

/// Live ``SteamAccountStoring``. The key lives only in the ``SecretStore`` (Keychain); the non-secret
/// SteamID64 lives in `UserDefaults`.
@MainActor
final class SteamAccountStore: SteamAccountStoring {
    private static let steamIDDefaultsKey = "steam.steamID64"
    private let secrets: any SecretStore
    private let defaults: UserDefaults

    /// Creates the store.
    init(secrets: any SecretStore, defaults: UserDefaults = .standard) {
        self.secrets = secrets
        self.defaults = defaults
    }

    var hasAPIKey: Bool {
        ((try? secrets.secret(for: .steamWebAPIKey)) ?? nil)?.isEmpty == false
    }

    func hasAPIKeyOffMain() async -> Bool {
        let secrets = secrets
        return await Task.detached(priority: .utility) {
            ((try? secrets.secret(for: .steamWebAPIKey)) ?? nil)?.isEmpty == false
        }.value
    }

    var steamID: SteamID? {
        defaults.string(forKey: Self.steamIDDefaultsKey).flatMap(SteamID.init)
    }

    func saveAPIKey(_ key: String) throws {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return try removeAPIKey() }
        try secrets.setSecret(trimmed, for: .steamWebAPIKey)
    }

    func removeAPIKey() throws {
        try secrets.removeSecret(for: .steamWebAPIKey)
    }

    func saveSteamID(_ steamID: SteamID?) {
        defaults.set(steamID?.rawValue, forKey: Self.steamIDDefaultsKey)
    }

    /// The key is read off the main thread (crash pass, ADR 0044): a Keychain read can wait on a permission prompt.
    func credentials() async throws -> SteamCredentials {
        let secrets = secrets
        let key = try await Task.detached(priority: .utility) {
            try secrets.secret(for: .steamWebAPIKey)
        }.value
        guard let key, !key.isEmpty else { throw SteamError.missingAPIKey }
        guard let steamID else { throw SteamError.missingSteamID }
        return SteamCredentials(apiKey: key, steamID: steamID)
    }
}
