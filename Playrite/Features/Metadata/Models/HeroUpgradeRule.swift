import Foundation
import ImageIO

/// When official key art may replace a hero the game already has (ADR 0038): only when the current hero is
/// community art from SteamGridDB **and** the official image is larger. Heroes chosen by hand, imported, or from
/// another official source are never replaced, and every swap is reported.
enum HeroUpgradeRule {
    /// Whether a candidate `candidatePixelWidth` wide is clearly better than the current hero.
    static func isClearlyBetter(
        currentSource: MetadataSource?,
        currentPixelWidth: Int?,
        candidatePixelWidth: Int
    ) -> Bool {
        guard currentSource == .steamGridDB else { return false }
        return (currentPixelWidth ?? 0) < candidatePixelWidth
    }

    /// Pixel width of the image at `path`, read from its header, or `nil`.
    static func pixelWidth(ofImageAt path: String?) -> Int? {
        guard let path,
              let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        else { return nil }
        return properties[kCGImagePropertyPixelWidth] as? Int
    }
}
