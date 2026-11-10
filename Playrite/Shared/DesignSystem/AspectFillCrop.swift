import CoreGraphics

/// The centred crop that fills a frame of `targetAspect` from an image, like a print trimmed to a box face (ADR 0039).
/// Used only for the game case's printed faces; slideshows and trailers never crop (ADR 0038).
enum AspectFillCrop {
    private static let half: CGFloat = 0.5
    /// The rect, in the image's pixel space, to keep.
    static func rect(imageSize: CGSize, targetAspect: CGFloat) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0, targetAspect > 0 else { return .zero }
        let imageAspect = imageSize.width / imageSize.height
        if imageAspect > targetAspect {
            let width = imageSize.height * targetAspect
            return CGRect(x: (imageSize.width - width) * half, y: 0, width: width, height: imageSize.height)
        }
        let height = imageSize.width / targetAspect
        return CGRect(x: 0, y: (imageSize.height - height) * half, width: imageSize.width, height: height)
    }
}
