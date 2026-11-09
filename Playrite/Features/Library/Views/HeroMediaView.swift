import AppKit
import SwiftUI

/// Wide hero/background slot at the top of the details centre: the hero image followed by carousel slides
/// (screenshots, trailer thumbnails), all rendered from the local artwork cache. Falls back to the cover, then a
/// placeholder.
struct HeroMediaView: View {
    /// Hero image path.
    let heroImagePath: String?
    /// Cover path used when there is no hero image.
    let coverImagePath: String?
    /// Extra carousel slides.
    var carouselImagePaths: [String] = []
    @State private var index = 0
    @Environment(\.designIntensity) private var intensity

    var body: some View {
        Theme.placeholder
            .frame(maxWidth: .infinity)
            .frame(height: EnergyLevel.of(intensity).detailHeroHeight)
            .overlay {
                // An overlay takes the placeholder's size, so a wide image fills it without widening the column.
                if let image = currentImage {
                    Image(nsImage: image).resizable().scaledToFill()
                } else {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(DesignTokens.Typography.largeTitle)
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(alignment: .bottomTrailing) {
                if slides.count > 1 {
                    controls
                }
            }
            .accessibilityElement(children: .contain)
    }

    private var controls: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Button("Previous image", systemImage: "chevron.left") { step(by: -1) }
            Text("\(index + 1) / \(slides.count)")
                .font(DesignTokens.Typography.monospacedSmall)
            Button("Next image", systemImage: "chevron.right") { step(by: 1) }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .padding(DesignTokens.Spacing.sm)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(DesignTokens.Spacing.md)
    }

    /// Hero (or cover) first, then carousel slides.
    private var slides: [String] {
        [heroImagePath ?? coverImagePath].compactMap(\.self) + carouselImagePaths
    }

    private var currentImage: NSImage? {
        let paths = slides
        guard !paths.isEmpty else { return nil }
        return NSImage(contentsOfFile: paths[min(index, paths.count - 1)])
    }

    private func step(by offset: Int) {
        let count = slides.count
        guard count > 0 else { return }
        index = (index + offset + count) % count
    }
}

#Preview {
    HeroMediaView(heroImagePath: nil, coverImagePath: nil)
        .padding(DesignTokens.Spacing.lg)
}
