import Foundation

/// Storage for secrets. The only live implementation is the Keychain (``KeychainSecretStore``).
protocol SecretStore: Sendable {
    /// Returns the secret, or `nil` when none is stored.
    func secret(for key: SecretKey) throws -> String?
    /// Stores or replaces a secret.
    func setSecret(_ value: String, for key: SecretKey) throws
    /// Removes a secret if present.
    func removeSecret(for key: SecretKey) throws
}
