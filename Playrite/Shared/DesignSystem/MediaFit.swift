import CoreGraphics

/// The size that shows a whole image (media pass, ADR 0038): as wide as the space allows, unless that would make it
/// taller than `maxHeight`, in which case it narrows. The result always has the image's own aspect ratio, so an
/// image in it is never cropped and never letterboxed.
enum MediaFit {
    /// The fitted size for an image of `aspect` (width ÷ height) in `availableWidth`, no taller than `maxHeight`.
    /// Returns `.zero` until there is a width and a usable aspect.
    static func size(aspect: CGFloat, availableWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        guard aspect.isFinite, aspect > 0, availableWidth > 0, maxHeight > 0 else { return .zero }
        let height = min(availableWidth / aspect, maxHeight)
        return CGSize(width: height * aspect, height: height)
    }

    /// Width ÷ height of an image of `size`, or `nil` when it has no area.
    static func aspect(of size: CGSize) -> CGFloat? {
        guard size.width > 0, size.height > 0 else { return nil }
        return size.width / size.height
    }
}
