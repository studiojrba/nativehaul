import AppKit
import SwiftUI

/// Official screenshots above a job's title (ADR 0028): crossfades to the next image every 3 seconds and loops. The
/// frame takes each slide's own shape (ADR 0038), so the whole image is always visible, never cropped. It pauses while
/// hovered; with Reduce Motion it shows the first image only, still. Images
/// decode off the main thread behind a quiet placeholder, so the build UI never waits. It has no
/// gestures, so it never takes clicks meant for the build controls.
struct BuildShowcaseView: View {
    /// What to show.
    let showcase: BuildShowcase
    /// Tallest the media may be (TV mode sizes it from the screen, ADR 0052).
    var maxHeight: CGFloat = DesignTokens.Media.showcaseMaxHeight
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var index = 0
    @State private var loaded: [Int: NSImage] = [:]
    @State private var isHovered = false

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
        FittedMediaFrame(aspect: currentAspect, maxHeight: maxHeight) {
            Theme.surface
                .overlay {
                    if let image = loaded[index] {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .id(index)
                            .transition(.opacity)
                    }
                }
                .clipShape(shape)
                .overlay(shape.strokeBorder(Theme.hairline))
        }
        .onHover { isHovered = $0 }
        .accessibilityHidden(true)
        .task(id: showcase) { await run() }
    }

    /// The showing slide's own shape (16:9 until it has loaded).
    private var currentAspect: CGFloat {
        loaded[index].flatMap { MediaFit.aspect(of: $0.size) } ?? DesignTokens.Media.fallbackAspect
    }

    private var rotates: Bool {
        showcase.isSlideshow && !reduceMotion
    }

    private func run() async {
        index = 0
        loaded = [:]
        let paths = rotates ? showcase.images : Array(showcase.images.prefix(1))
        for (position, path) in paths.enumerated() {
            if let image = await Self.decodeImage(atPath: path) {
                loaded[position] = image.nsImage
            }
        }
        guard rotates, loaded.count > 1 else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(DesignTokens.Builds.slideSeconds))
            guard !Task.isCancelled, !isHovered else { continue }
            let next = (index + 1) % paths.count
            guard loaded[next] != nil else {
                index = next
                continue
            }
            withAnimation(.easeInOut(duration: DesignTokens.Builds.crossfadeSeconds)) { index = next }
        }
    }

    /// Decodes a downscaled copy off the main thread (`nil` for a missing or unreadable file).
    static func decodeImage(atPath path: String) async -> DecodedImage? {
        await Task.detached(priority: .utility) {
            let url = URL(fileURLWithPath: path) as CFURL
            guard let source = CGImageSourceCreateWithURL(url, nil),
                  let image = CGImageSourceCreateThumbnailAtIndex(source, 0, [
                      kCGImageSourceCreateThumbnailFromImageAlways: true,
                      kCGImageSourceThumbnailMaxPixelSize: DesignTokens.Builds.showcaseDecodePixels,
                      kCGImageSourceCreateThumbnailWithTransform: true,
                  ] as CFDictionary)
            else { return nil }
            return DecodedImage(image: image)
        }.value
    }
}

#Preview {
    BuildShowcaseView(showcase: BuildShowcase(images: [], isSlideshow: false))
        .frame(width: DesignTokens.Layout.detailMinWidth)
        .padding(DesignTokens.Spacing.xl)
}
