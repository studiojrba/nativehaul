import AppKit
import SwiftUI

/// Official screenshots above a job's title (ADR 0028): a fixed 16:9 area that crossfades to the next image every
/// 3 seconds and loops. It pauses while hovered; with Reduce Motion it shows the first image only, still. Images
/// decode off the main thread behind a quiet placeholder, so nothing shifts and the build UI never waits. It has no
/// gestures, so it never takes clicks meant for the build controls.
struct BuildShowcaseView: View {
    /// What to show.
    let showcase: BuildShowcase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var index = 0
    @State private var loaded: [Int: NSImage] = [:]
    @State private var isHovered = false

    var body: some View {
        Theme.surface
            .frame(maxWidth: .infinity)
            .aspectRatio(1 / DesignTokens.Builds.showcaseHeightRatio, contentMode: .fit)
            .overlay {
                if let image = loaded[index] {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .id(index)
                        .transition(.opacity)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg).strokeBorder(Theme.hairline))
            .onHover { isHovered = $0 }
            .accessibilityHidden(true)
            .task(id: showcase) { await run() }
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
