import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

/// Writes a PNG of an exact pixel size (NSImage drawing doubles pixels on Retina), for tests that read image headers.
enum PixelImageFile {
    /// Path of a new solid PNG `width` × `height` pixels.
    static func write(width: Int, height: Int) -> String? {
        let url = FileManager.default.temporaryDirectory.appending(path: "pixel-\(UUID().uuidString).png")
        guard let context = CGContext(
                  data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                  space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
              ), let image = context.makeImage(),
              let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)
        else { return nil }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return url.path(percentEncoded: false)
    }
}
