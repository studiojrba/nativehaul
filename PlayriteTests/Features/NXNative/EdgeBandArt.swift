import AppKit

/// Test art with a coloured band along each edge (red top, green bottom, blue left, yellow right) over a grey
/// middle, so a render shows at a glance whether any side was cropped.
@MainActor
enum EdgeBandArt {
    /// Band thickness as a share of the shorter side.
    private static let bandShare: CGFloat = 0.03
    /// One band colour.
    enum Band: CaseIterable {
        case top, bottom, left, right

        /// Its colour.
        var color: NSColor {
            switch self {
            case .top: NSColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
            case .bottom: NSColor(srgbRed: 0, green: 1, blue: 0, alpha: 1)
            case .left: NSColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)
            case .right: NSColor(srgbRed: 1, green: 1, blue: 0, alpha: 1)
            }
        }

        /// Whether a rendered pixel is this band's colour. Renders come back in Display P3, so the rules check the
        /// dominant channels loosely; the grey middle (about 128 on every channel) never matches.
        func matches(red: Int, green: Int, blue: Int) -> Bool {
            let high = 200
            let low = 130
            let dark = 80
            switch self {
            case .top: return red > high && green < low && blue < low
            case .bottom: return green > high && red < low + dark / 2 && blue < low
            case .left: return blue > high && red < dark && green < dark
            case .right: return red > high && green > high && blue < low
            }
        }
    }

    /// Writes the art at `size` and returns its path.
    static func write(name: String, size: CGSize) -> String {
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor(srgbRed: 0.5, green: 0.5, blue: 0.5, alpha: 1).setFill()
        NSRect(origin: .zero, size: size).fill()
        let band = (min(size.width, size.height) * bandShare).rounded(.up)
        Band.left.color.setFill()
        NSRect(x: 0, y: band, width: band, height: size.height - 2 * band).fill()
        Band.right.color.setFill()
        NSRect(x: size.width - band, y: band, width: band, height: size.height - 2 * band).fill()
        Band.bottom.color.setFill()
        NSRect(x: band, y: 0, width: size.width - 2 * band, height: band).fill()
        Band.top.color.setFill()
        NSRect(x: band, y: size.height - band, width: size.width - 2 * band, height: band).fill()
        image.unlockFocus()
        let folder = OffscreenRenderer.folder
        try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
        let path = (folder as NSString).appendingPathComponent("edge-bands-\(name).png")
        if let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) {
            try? bitmap.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
        }
        return path
    }

    /// Which bands are visible in the render at `path`, and the bounding box of every band pixel.
    static func inspect(renderAt path: String) -> (visible: Set<Band>, bounds: CGRect)? {
        guard let bitmap = NSImage(contentsOfFile: path).flatMap({ $0.representations.first as? NSBitmapImageRep })
        else { return nil }
        var visible: Set<Band> = []
        var minX = Int.max, minY = Int.max, maxX = Int.min, maxY = Int.min
        for y in 0 ..< bitmap.pixelsHigh {
            for x in 0 ..< bitmap.pixelsWide {
                guard let color = bitmap.colorAt(x: x, y: y) else { continue }
                let channels = (
                    Int(color.redComponent * 255),
                    Int(color.greenComponent * 255),
                    Int(color.blueComponent * 255)
                )
                guard let band = Band.allCases.first(where: { $0.matches(
                    red: channels.0,
                    green: channels.1,
                    blue: channels.2
                ) })
                else { continue }
                visible.insert(band)
                minX = min(minX, x); maxX = max(maxX, x); minY = min(minY, y); maxY = max(maxY, y)
            }
        }
        guard !visible.isEmpty else { return ([], .zero) }
        return (visible, CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1))
    }
}
