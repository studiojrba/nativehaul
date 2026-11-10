import Foundation

/// A trailer a provider offers (ADR 0038): a stream URL that is played, never downloaded, and poster images to cache.
struct TrailerCandidate: Equatable, Sendable {
    /// Stream URL (HLS or mp4, or a YouTube watch URL).
    let videoURL: URL
    /// Poster candidates, best first.
    let posterCandidates: [URL]
}
