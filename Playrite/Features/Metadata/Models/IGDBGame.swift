import Foundation

/// The fields Retriever reads from an IGDB `games` result (ADR 0038).
struct IGDBGame: Decodable, Equatable, Sendable {
    /// One expanded image or video reference.
    struct Media: Decodable, Equatable, Sendable {
        /// Image ID (screenshots).
        let imageId: String?
        /// YouTube video ID (videos).
        let videoId: String?
    }

    /// IGDB game ID.
    let id: Int
    /// Name.
    let name: String
    /// Plain-text summary.
    let summary: String?
    /// Screenshots, in IGDB's order.
    let screenshots: [Media]?
    /// Videos (YouTube IDs), in IGDB's order.
    let videos: [Media]?
}
