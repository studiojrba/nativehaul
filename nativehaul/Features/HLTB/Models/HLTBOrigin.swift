import Foundation

/// How an estimate entered the cache.
enum HLTBOrigin: String, Codable, Sendable {
    /// Typed in by the user after looking it up on HowLongToBeat.
    case manual
    /// Returned by a configured remote source.
    case remote
}
