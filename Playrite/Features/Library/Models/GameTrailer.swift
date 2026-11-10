import Foundation

/// A game's trailer as the media set plays it (ADR 0038), parsed from ``Game/trailerVideoURL``.
enum GameTrailer: Equatable, Sendable {
    /// A stream AVPlayer plays natively (Steam's HLS playlist or an mp4).
    case stream(URL)

    /// The trailer for a stored URL string, or `nil` when there is none or it isn't a usable URL.
    init?(storedURL: String?) {
        guard let storedURL, let url = URL(string: storedURL), let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http"
        else { return nil }
        self = .stream(url)
    }
}
