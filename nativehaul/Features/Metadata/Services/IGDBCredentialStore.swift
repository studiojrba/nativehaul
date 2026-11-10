import Foundation

/// Live ``IGDBCredentialStoring`` over the Keychain-backed ``SecretStore``. The credentials are never written
/// anywhere else and never read back into the UI.
struct IGDBCredentialStore: IGDBCredentialStoring {
    private let secrets: any SecretStore

    /// Creates the store.
    init(secrets: any SecretStore) {
        self.secrets = secrets
    }

    func credentials() -> IGDBCredentials? {
        guard let clientID = (try? secrets.secret(for: .twitchClientID)) ?? nil, !clientID.isEmpty,
              let clientSecret = (try? secrets.secret(for: .twitchClientSecret)) ?? nil, !clientSecret.isEmpty
        else { return nil }
        return IGDBCredentials(clientID: clientID, clientSecret: clientSecret)
    }

    func save(clientID: String, clientSecret: String) throws {
        let id = clientID.trimmingCharacters(in: .whitespacesAndNewlines)
        let secret = clientSecret.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !id.isEmpty, !secret.isEmpty else { return try remove() }
        try secrets.setSecret(id, for: .twitchClientID)
        try secrets.setSecret(secret, for: .twitchClientSecret)
    }

    func remove() throws {
        try secrets.removeSecret(for: .twitchClientID)
        try secrets.removeSecret(for: .twitchClientSecret)
    }
}
