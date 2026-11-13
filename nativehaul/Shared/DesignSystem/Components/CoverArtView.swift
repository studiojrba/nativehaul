import AppKit
import SwiftUI

/// Portrait cover art loaded from a local file, else the game's drawn cover (``ProceduralCover``).
struct CoverArtView: View {
    /// Absolute path to an image on disk.
    let imagePath: String?
    /// Title used for the placeholder and accessibility.
    let title: String
    /// Rendered width; height follows ``DesignTokens/Cover/aspectRatio``.
    var width: CGFloat?

    var body: some View {
        content
            .aspectRatio(DesignTokens.Cover.widthToHeight, contentMode: .fit)
            .frame(width: width)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            .accessibilityLabel(Text(title))
    }

    @ViewBuilder private var content: some View {
        if let imagePath, let image = NSImage(contentsOfFile: imagePath) {
            Image(nsImage: image).resizable().scaledToFill()
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ProceduralCover(title: title, baseSize: TypeStyle.Size.small)
    }
}

#Preview {
    CoverArtView(imagePath: nil, title: "Skyward Lanterns", width: DesignTokens.Cover.minWidth)
        .padding(DesignTokens.Spacing.lg)
}
