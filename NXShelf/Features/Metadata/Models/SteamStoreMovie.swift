import Foundation

/// A Steam store trailer (ADR 0038). It is streamed, never downloaded: the HLS playlist Steam serves today, or the
/// mp4 files older payloads list.
struct SteamStoreMovie: Decodable, Sendable {
    /// Thumbnail image URL (293×165).
    let thumbnail: String?
    /// Whether Steam features this trailer first on the store page.
    let highlight: Bool?
    /// HLS master playlist (H.264), the current payload shape.
    let hlsH264: String?
    /// mp4 files by quality ("480", "max"), the older payload shape.
    let mp4: [String: String]?

    /// The best stream to play: HLS, then the largest mp4.
    var streamURL: URL? {
        [hlsH264, mp4?["max"], mp4?["480"]].lazy.compactMap { $0.flatMap(URL.init(string:)) }.first
    }
}
