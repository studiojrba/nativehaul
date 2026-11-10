import Foundation

/// Errors raised by metadata providers.
enum MetadataError: Error, Equatable {
    /// The store answered with an unexpected HTTP status.
    case http(status: Int)
    /// The response could not be decoded.
    case decoding
    /// The SteamGridDB key was rejected.
    case invalidAPIKey
    /// A request URL could not be built.
    case badURL
}
