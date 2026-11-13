import CoreGraphics
import Foundation
import ImageIO

/// Live ``GamePaletteExtracting``: downsamples the cover to a tiny thumbnail with ImageIO (fast, never decodes the
/// full image), reads its pixels and hands them to ``PaletteAnalysis``. Runs off the main actor.
struct ArtworkPaletteExtractor: GamePaletteExtracting {
    /// Longest edge, in pixels, the artwork is reduced to before analysis.
    static let sampleEdge = 32

    private static let bytesPerPixel = 4
    private static let bitsPerComponent = 8

    func palette(forImageAt url: URL?) async -> GamePalette {
        guard let url, let pixels = Self.pixels(at: url) else { return .neutral }
        return PaletteAnalysis.palette(from: pixels)
    }

    /// The image's pixels after downsampling, as opaque sRGB colours (transparent pixels skipped).
    static func pixels(at url: URL) -> [RGBA]? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: sampleEdge,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }
        return pixels(of: image)
    }

    /// Draws `image` into an sRGB RGBA buffer and returns its opaque pixels.
    static func pixels(of image: CGImage) -> [RGBA]? {
        let width = image.width
        let height = image.height
        guard width > 0, height > 0, let space = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        var bytes = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        let drawn: Bool = bytes.withUnsafeMutableBytes { buffer in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: bitsPerComponent,
                bytesPerRow: width * bytesPerPixel,
                space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        return stride(from: 0, to: bytes.count, by: bytesPerPixel).compactMap { index in
            let alpha = bytes[index + Channel.alpha]
            guard alpha > 0 else { return nil }
            let scale = Double(UInt8.max) / Double(alpha)
            let unpremultiplied = { (byte: UInt8) in Int((Double(byte) * scale).rounded()) }
            return RGBA(
                red8: unpremultiplied(bytes[index + Channel.red]),
                green8: unpremultiplied(bytes[index + Channel.green]),
                blue8: unpremultiplied(bytes[index + Channel.blue])
            )
        }
    }

    /// Byte offsets within one RGBA pixel.
    private enum Channel {
        static let red = 0
        static let green = 1
        static let blue = 2
        static let alpha = 3
    }
}
