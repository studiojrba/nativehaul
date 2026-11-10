import Foundation

/// Live ``RetroAchievementsCredentialStoring`` over the Keychain-backed ``SecretStore``. Never read back into the UI.
struct RetroAchievementsCredentialStore: RetroAchievementsCredentialStoring {
    private let secrets: any SecretStore

    /// Creates the store.
    init(secrets: any SecretStore) {
        self.secrets = secrets
    }

    func credentials() -> RetroAchievementsCredentials? {
        guard let username = (try? secrets.secret(for: .retroAchievementsUsername)) ?? nil, !username.isEmpty,
              let apiKey = (try? secrets.secret(for: .retroAchievementsAPIKey)) ?? nil, !apiKey.isEmpty
        else { return nil }
        return RetroAchievementsCredentials(username: username, apiKey: apiKey)
    }

    func save(username: String, apiKey: String) throws {
        let user = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !user.isEmpty, !key.isEmpty else { return try remove() }
        try secrets.setSecret(user, for: .retroAchievementsUsername)
        try secrets.setSecret(key, for: .retroAchievementsAPIKey)
    }

    func remove() throws {
        try secrets.removeSecret(for: .retroAchievementsUsername)
        try secrets.removeSecret(for: .retroAchievementsAPIKey)
    }
}
