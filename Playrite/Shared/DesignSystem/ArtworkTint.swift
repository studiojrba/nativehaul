import AppKit
import CoreImage
import SwiftUI

/// Colour sampled from a game's own artwork (ADR 0025, the Apple TV / Steam pattern): the average of a small copy of
/// the image, lifted to a minimum saturation and a fixed brightness so it reads as colour without fighting text.
/// Results are cached per file.
@MainActor
enum ArtworkTint {
    private static let cache = NSCache<NSString, NSColor>()
    private static let context = CIContext(options: [.workingColorSpace: NSNull()])
    private static let rgbaChannels = 4
    private static let red = 0
    private static let green = 1
    private static let blue = 2

    /// The tint for the image at `path`, or `nil` when there's no readable image.
    static func color(forImageAt path: String?) -> Color? {
        nsColor(forImageAt: path).map(Color.init(nsColor:))
    }

    /// The tint as an AppKit colour (for SceneKit materials), or `nil` when there's no readable image.
    static func nsColor(forImageAt path: String?) -> NSColor? {
        guard let path else { return nil }
        if let cached = cache.object(forKey: path as NSString) {
            return cached
        }
        guard let sampled = sample(path) else { return nil }
        cache.setObject(sampled, forKey: path as NSString)
        return sampled
    }

    private static func sample(_ path: String) -> NSColor? {
        guard let image = CIImage(contentsOf: URL(fileURLWithPath: path)), !image.extent.isEmpty else { return nil }
        let scale = DesignTokens.ArtTint.sampleSize / max(image.extent.width, image.extent.height)
        let small = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [
            kCIInputImageKey: small,
            kCIInputExtentKey: CIVector(cgRect: small.extent),
        ]), let output = filter.outputImage else { return nil }
        var pixel = [UInt8](repeating: 0, count: rgbaChannels)
        context.render(
            output, toBitmap: &pixel, rowBytes: pixel.count,
            bounds: CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), format: .RGBA8, colorSpace: nil
        )
        let average = NSColor(
            srgbRed: CGFloat(pixel[red]) / CGFloat(UInt8.max),
            green: CGFloat(pixel[green]) / CGFloat(UInt8.max),
            blue: CGFloat(pixel[blue]) / CGFloat(UInt8.max),
            alpha: 1
        )
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        average.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return NSColor(
            hue: hue,
            saturation: max(saturation, DesignTokens.ArtTint.minimumSaturation),
            brightness: DesignTokens.ArtTint.brightness,
            alpha: 1
        )
    }
}
