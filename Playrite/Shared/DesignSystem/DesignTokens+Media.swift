import CoreGraphics

extension DesignTokens {
    /// Slideshow and trailer framing (media pass, ADR 0038): the frame follows each slide's own shape, so nothing is
    /// ever cropped.
    enum Media {
        /// Shape assumed before an image has loaded, and for trailers (16:9), as width divided by height.
        static let fallbackAspect: CGFloat = 1.777_777_8
        /// Tallest the Builds showcase may grow; a taller-than-wide slide narrows instead of cropping.
        static let showcaseMaxHeight: CGFloat = 480
        /// How long the frame takes to follow a slide of a different shape.
        static let resizeSeconds: Double = 0.35
    }
}
