import AppKit

/// Decoded artwork kept in memory, so shelves and grids don't re-read the same files on every render.
@MainActor
enum ArtworkImageCache {
    private static let cache = NSCache<NSString, NSImage>()

    /// The image at `path`, from the cache or disk; `nil` for a missing or unreadable file.
    static func image(atPath path: String?) -> NSImage? {
        guard let path, !path.isEmpty else { return nil }
        if let cached = cache.object(forKey: path as NSString) {
            return cached
        }
        guard let image = NSImage(contentsOfFile: path) else { return nil }
        cache.setObject(image, forKey: path as NSString)
        return image
    }
}
