import SwiftUI

/// Artwork filling its frame edge to edge (spec §1.8: full-bleed, no borders), richer at night. With no readable image
/// it shows a warm placeholder with the title in the display face. The caller sizes and clips it.
struct ArtworkFill: View {
    /// Absolute path to the image.
    let path: String?
    /// Shown on the placeholder and read by VoiceOver.
    let title: String
    /// Placeholder title size.
    var placeholderSize: CGFloat = TypeStyle.DisplaySize.tagline
    /// Whether the placeholder shows the title.
    var showsTitle = true

    var body: some View {
        Group {
            if let image = ArtworkImageCache.image(atPath: path) {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .nightArtwork()
            } else {
                ZStack {
                    Theme.cream2
                    if showsTitle {
                        Text(title)
                            .font(Typeface.display(placeholderSize))
                            .foregroundStyle(Theme.inkSoft)
                            .multilineTextAlignment(.center)
                            .lineLimit(DesignTokens.Lines.title)
                            .minimumScaleFactor(DesignTokens.Typography.minimumScale)
                            .padding(DesignTokens.Spacing.md)
                    }
                }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .clipped()
        .accessibilityLabel(Text(title))
    }
}

#Preview {
    AppearancePreviewPair {
        ArtworkFill(path: nil, title: "Lantern Coast")
            .frame(width: DesignTokens.Cover.minWidth, height: DesignTokens.Cover.minWidth)
            .clipShape(RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous))
            .padding(DesignTokens.Spacing.xl)
    }
}
