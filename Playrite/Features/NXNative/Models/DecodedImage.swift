import AppKit
import CoreGraphics

/// A decoded image handed from a background decode to the main actor.
struct DecodedImage: @unchecked Sendable {
    // Safe: the CGImage is immutable once decoded, and it is only read after the hand-off.
    let image: CGImage

    /// The image for SwiftUI.
    var nsImage: NSImage {
        NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
    }
}
