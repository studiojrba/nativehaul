import CryptoKit
import Foundation

/// SHA-256 helpers.
enum SHA256Hasher {
    /// Lower-case hex digest of `data`.
    static func hex(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}
