import AppKit
import SwiftUI

/// Renders a SwiftUI view offscreen to a PNG in a borderless window with a fixed appearance, for visual checks.
@MainActor
enum OffscreenRenderer {
    /// Where renders go.
    static let folder = (NSTemporaryDirectory() as NSString).appendingPathComponent("RetrieverPolish")
    private static let settle: TimeInterval = 0.4

    /// Renders `view` at `size` and saves `<name>.png`; returns the path.
    @discardableResult
    static func render(_ view: some View, size: CGSize, name: String, appearance: NSAppearance.Name) -> String? {
        let hosting = NSHostingView(rootView: view.frame(width: size.width, height: size.height))
        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.appearance = NSAppearance(named: appearance)
        window.contentView = hosting
        hosting.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(settle))
        guard let bitmap = hosting.bitmapImageRepForCachingDisplay(in: hosting.bounds) else { return nil }
        hosting.cacheDisplay(in: hosting.bounds, to: bitmap)
        try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
        let path = (folder as NSString).appendingPathComponent("\(name).png")
        try? bitmap.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
        return path
    }

    /// Writes a simple two-colour artwork image (a stand-in for real box art) and returns its path.
    static func placeholderArt(name: String, hue: CGFloat, size: CGSize) -> String {
        let image = NSImage(size: size)
        image.lockFocus()
        let top = NSColor(hue: hue, saturation: 0.75, brightness: 0.85, alpha: 1)
        let bottom = NSColor(
            hue: (hue + 0.08).truncatingRemainder(dividingBy: 1),
            saturation: 0.9,
            brightness: 0.35,
            alpha: 1
        )
        NSGradient(starting: top, ending: bottom)?.draw(in: NSRect(origin: .zero, size: size), angle: -70)
        NSColor(white: 1, alpha: 0.18).setFill()
        NSBezierPath(ovalIn: NSRect(
            x: size.width * 0.2,
            y: size.height * 0.45,
            width: size.width * 0.6,
            height: size.width * 0.6
        )).fill()
        image.unlockFocus()
        try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
        let path = (folder as NSString).appendingPathComponent("art-\(name).png")
        if let tiff = image.tiffRepresentation, let bitmap = NSBitmapImageRep(data: tiff) {
            try? bitmap.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: path))
        }
        return path
    }
}
