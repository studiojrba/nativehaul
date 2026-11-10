import AppKit
import ImageIO

/// Draws the case's printed faces (ADR 0039). Art is trimmed to the face like a printed box (``AspectFillCrop``):
/// this is the one place the no-crop rule (ADR 0038) does not apply.
@MainActor
enum GameCaseTextures {
    private typealias Tokens = DesignTokens.GameCase
    private static let half: CGFloat = 0.5

    /// The front or back face from the image at `path`, or `nil` when it can't be read.
    static func face(from path: String?) -> NSImage? {
        guard let path,
              let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: path) as CFURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                  kCGImageSourceCreateThumbnailFromImageAlways: true,
                  kCGImageSourceThumbnailMaxPixelSize: Tokens.texturePixels,
                  kCGImageSourceCreateThumbnailWithTransform: true,
              ] as CFDictionary)
        else { return nil }
        let crop = AspectFillCrop.rect(
            imageSize: CGSize(width: image.width, height: image.height),
            targetAspect: Tokens.faceAspect
        )
        guard let trimmed = image.cropping(to: crop.integral) else { return nil }
        return NSImage(cgImage: trimmed, size: NSSize(width: trimmed.width, height: trimmed.height))
    }

    /// The spine: the title running top to bottom on the case colour.
    static func spine(title: String, color: NSColor) -> NSImage {
        let height = Tokens.texturePixels
        let width = (height * Tokens.spineAspect).rounded()
        let size = NSSize(width: width, height: height)
        return NSImage(size: size, flipped: false) { rect in
            color.setFill()
            rect.fill()
            let font = NSFont.systemFont(ofSize: width * Tokens.spineTitleShare, weight: .heavy)
            let style = NSMutableParagraphStyle()
            style.lineBreakMode = .byTruncatingTail
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: Palette.color(Palette.caseSpineText),
                .paragraphStyle: style,
            ]
            let inset = height * Tokens.spineTitleInset
            NSGraphicsContext.current?.saveGraphicsState()
            let transform = NSAffineTransform()
            transform.translateX(by: width * half, yBy: height - inset)
            transform.rotate(byDegrees: Tokens.spineRotationDegrees)
            transform.concat()
            let line = NSRect(
                x: 0,
                y: -font.capHeight,
                width: height - inset - inset,
                height: font.pointSize * Tokens.spineLineHeight
            )
            (title as NSString).draw(
                with: line,
                options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                attributes: attributes
            )
            NSGraphicsContext.current?.restoreGraphicsState()
            return true
        }
    }

    /// The plastic edge colour: the art's tint, darkened.
    static func edgeColor(from tint: NSColor) -> NSColor {
        tint.blended(withFraction: Tokens.edgeDarkening, of: .black) ?? tint
    }
}
