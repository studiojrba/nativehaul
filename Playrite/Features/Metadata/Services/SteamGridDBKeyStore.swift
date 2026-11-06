import Foundation

/// Live ``SteamGridDBKeyStoring`` over the Keychain-backed ``SecretStore``. The key is never written elsewhere.
@MainActor
final class SteamGridDBKeyStore: SteamGridDBKeyStoring {
    private let secrets: any SecretStore

    /// Creates the store.
    init(secrets: any SecretStore) {
        self.secrets = secrets
    }

    var hasKey: Bool {
        ((try? secrets.secret(for: .steamGridDBAPIKey)) ?? nil)?.isEmpty == false
    }

    func saveKey(_ key: String) throws {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return try removeKey() }
        try secrets.setSecret(trimmed, for: .steamGridDBAPIKey)
    }

    func removeKey() throws {
        try secrets.removeSecret(for: .steamGridDBAPIKey)
    }
}
