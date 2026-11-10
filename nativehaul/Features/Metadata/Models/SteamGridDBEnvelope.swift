import Foundation

/// SteamGridDB API v2 response wrapper.
struct SteamGridDBEnvelope<Payload: Decodable & Sendable>: Decodable, Sendable {
    /// Whether the call succeeded.
    let success: Bool
    /// The payload.
    let data: Payload?
}
