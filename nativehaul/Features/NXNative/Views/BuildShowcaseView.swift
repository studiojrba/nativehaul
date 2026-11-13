import AppKit
import SwiftUI

/// The screenshot slideshow on the Builds page (spec §3.4, ADR 0028/0038): each shot fitted to its own shape — never
/// cropped — and centred in a `surface` frame (6pt padding, radius 22, `elev-lg`). Shots crossfade over 1200ms, scaling
/// from 97%, every 3.6s, with dots underneath that jump to a shot. It pauses while hovered; under Reduce Motion it
/// shows the first shot, still. Images decode off the main thread, so the build UI never waits.
struct BuildShowcaseView: View {
    /// What to show.
    let showcase: BuildShowcase
    /// The stage's height (the shots fit inside it).
    var stageHeight: CGFloat = ShellLayout.Builds.stageMax

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var index = 0
    @State private var loaded: [Int: NSImage] = [:]
    @State private var isHovered = false
    @State private var stageWidth: CGFloat = 0

    private typealias Metrics = ShellLayout.Builds

    var body: some View {
        VStack(spacing: Metrics.dotsTop) {
            ZStack {
                ForEach(Array(loaded.keys.sorted()), id: \.self) { slide in
                    if let image = loaded[slide] {
                        shot(image, isShowing: slide == index)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: stageHeight)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { stageWidth = $0 }
            if rotates, loaded.count > 1 {
                SlideDots(count: showcase.images.count, index: index) { slide in
                    withAnimation(Motion.settle(Metrics.crossfade)) { index = slide }
                }
            }
        }
        .onHover { isHovered = $0 }
        .task(id: showcase) { await run() }
    }

    private func shot(_ image: NSImage, isShowing: Bool) -> some View {
        let aspect = MediaFit.aspect(of: image.size) ?? DesignTokens.Media.fallbackAspect
        let size = MediaFit.size(aspect: aspect, availableWidth: stageWidth, maxHeight: stageHeight)
        return Image(nsImage: image)
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: Metrics.shotRadius, style: .continuous))
            .padding(Metrics.shotFramePadding)
            .frame(width: size.width, height: size.height)
            .background(
                RoundedRectangle(cornerRadius: Metrics.shotFrameRadius, style: .continuous).fill(Theme.surface)
            )
            .elevation(.large)
            .opacity(isShowing ? 1 : 0)
            .scaleEffect(isShowing ? 1 : Metrics.shotRestScale)
            .accessibilityHidden(true)
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
            try? await Task.sleep(for: .seconds(Metrics.advance))
            guard !Task.isCancelled, !isHovered else { continue }
            var next = (index + 1) % paths.count
            while loaded[next] == nil {
                next = (next + 1) % paths.count
            }
            withAnimation(Motion.settle(Metrics.crossfade)) { index = next }
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
    BuildShowcaseView(showcase: BuildShowcase(images: [], isSlideshow: false), stageHeight: ShellLayout.Builds.stageMin)
        .frame(width: DesignTokens.Layout.detailMinWidth)
        .padding(DesignTokens.Spacing.xl)
}
