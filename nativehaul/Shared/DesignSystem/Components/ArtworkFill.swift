import SwiftUI

/// Artwork filling its frame edge to edge (spec §1.8: full-bleed, no borders), richer at night. With no readable image
/// it shows the game's drawn cover (``ProceduralCover``, 0.1.1 note 14: the drawn covers are the default). The caller
/// sizes and clips it.
struct ArtworkFill: View {
    /// Absolute path to the image.
    let path: String?
    /// Shown on the placeholder and read by VoiceOver.
    let title: String
    /// The drawn cover's title size.
    var placeholderSize: CGFloat = TypeStyle.DisplaySize.tagline
    /// The studio, shown on the drawn cover when known.
    var studio: String?
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
                ProceduralCover(
                    title: title,
                    studio: studio,
                    baseSize: placeholderSize / ShellLayout.DrawnCover.titleEm,
                    showsTitle: showsTitle
                )
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
