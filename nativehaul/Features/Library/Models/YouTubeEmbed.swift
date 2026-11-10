import Foundation

/// The YouTube IFrame player page for a trailer (ADR 0038). Embedding through YouTube's own player is the sanctioned
/// way to show its videos; nothing is downloaded.
enum YouTubeEmbed {
    private static let videoIDLength = 11
    private static let allowed = CharacterSet(charactersIn:
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_")
    /// The page's origin. YouTube's player needs a referrer, and HTML loaded from a string has none without one.
    static let baseURL = URL(string: "https://com.studiojrba.nativehaul")

    /// Whether `id` looks like a YouTube video ID (11 URL-safe characters).
    static func isValidVideoID(_ id: String) -> Bool {
        id.count == videoIDLength && id.unicodeScalars.allSatisfy(allowed.contains)
    }

    /// The video ID in a YouTube watch, short or embed URL, or `nil`.
    static func videoID(from url: URL) -> String? {
        guard let host = url.host()?.lowercased() else { return nil }
        let candidate: String? = if host == "youtu.be" {
            url.pathComponents.dropFirst().first
        } else if host.hasSuffix("youtube.com") || host.hasSuffix("youtube-nocookie.com") {
            url.pathComponents.contains("embed")
                ? url.pathComponents.last
                : URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?
                .first { $0.name == "v" }?.value
        } else {
            nil
        }
        return candidate.flatMap { isValidVideoID($0) ? $0 : nil }
    }

    /// The player page: muted, looping, autoplaying when `autoplay` is true. YouTube's own controls handle pause and
    /// sound.
    static func html(videoID: String, autoplay: Bool) -> String {
        let flag = autoplay ? 1 : 0
        let source = "https://www.youtube-nocookie.com/embed/\(videoID)?autoplay=\(flag)&mute=1&loop=1"
            + "&playlist=\(videoID)&playsinline=1&rel=0&controls=1"
        return """
        <!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1">
        <style>html,body{margin:0;height:100%;background:#000;overflow:hidden}
        iframe{border:0;width:100%;height:100%}</style>
        </head><body><iframe src="\(source)" allow="autoplay; encrypted-media; picture-in-picture"
        referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe></body></html>
        """
    }
}
