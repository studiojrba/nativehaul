import AppKit
import SwiftUI

/// Wide hero/background slot at the top of the details centre: the hero image followed by carousel slides
/// (screenshots), all rendered from the local artwork cache. Falls back to the cover, then a placeholder. The frame
/// takes each slide's own shape (ADR 0038), up to the dial's hero height, so a slide is never cropped.
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
        Group {
            if let image = currentImage {
                FittedMediaFrame(
                    aspect: MediaFit.aspect(of: image.size) ?? DesignTokens.Media.fallbackAspect,
                    maxHeight: heroHeight
                ) {
                    Image(nsImage: image).resizable().scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
                        .overlay(alignment: .bottomTrailing) { slideControls }
                }
            } else {
                Theme.placeholder
                    .frame(maxWidth: .infinity)
                    .frame(height: heroHeight)
                    .overlay {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(DesignTokens.Typography.largeTitle)
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
                    .overlay(alignment: .bottomTrailing) { slideControls }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var heroHeight: CGFloat {
        EnergyLevel.of(intensity).detailHeroHeight
    }

    @ViewBuilder private var slideControls: some View {
        if slides.count > 1 {
            controls
        }
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
