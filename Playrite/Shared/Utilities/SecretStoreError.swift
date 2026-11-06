import Foundation

/// Errors from ``SecretStore`` implementations.
enum SecretStoreError: Error, Equatable, LocalizedError {
    /// The Keychain returned an unexpected status code.
    case keychain(status: Int32)
    /// Stored data was not valid UTF-8.
    case invalidData

    /// User-facing description.
    var errorDescription: String? {
        switch self {
        case let .keychain(status): "Keychain error (\(status))."
        case .invalidData: "The stored secret could not be read."
        }
    }
}
