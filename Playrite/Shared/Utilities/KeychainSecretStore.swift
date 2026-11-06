import Foundation
import Security

/// ``SecretStore`` backed by the macOS Keychain (generic passwords). Secrets never touch disk elsewhere.
struct KeychainSecretStore: SecretStore {
    private let service: String

    /// Creates a store scoped to a Keychain service name.
    init(service: String = "com.studiojrba.Playrite") {
        self.service = service
    }

    func secret(for key: SecretKey) throws -> String? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else { throw SecretStoreError.keychain(status: status) }
        guard let data = result as? Data, let value = String(data: data, encoding: .utf8) else {
            throw SecretStoreError.invalidData
        }
        return value
    }

    func setSecret(_ value: String, for key: SecretKey) throws {
        let data = Data(value.utf8)
        let attributes = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(baseQuery(for: key) as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }
        guard updateStatus == errSecItemNotFound else { throw SecretStoreError.keychain(status: updateStatus) }
        var query = baseQuery(for: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let addStatus = SecItemAdd(query as CFDictionary, nil)
        guard addStatus == errSecSuccess else { throw SecretStoreError.keychain(status: addStatus) }
    }

    func removeSecret(for key: SecretKey) throws {
        let status = SecItemDelete(baseQuery(for: key) as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecretStoreError.keychain(status: status)
        }
    }

    private func baseQuery(for key: SecretKey) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
        ]
    }
}
