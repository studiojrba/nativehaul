import AppKit
import SwiftUI

/// Portrait cover art loaded from a local file, with a token-driven placeholder.
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
        ZStack {
            Theme.placeholder
            VStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "gamecontroller")
                    .font(DesignTokens.Typography.title)
                    .foregroundStyle(Theme.secondaryText)
                Text(title)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(DesignTokens.Lines.title)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
            }
        }
    }
}

#Preview {
    CoverArtView(imagePath: nil, title: "Skyward Lanterns", width: DesignTokens.Cover.minWidth)
        .padding(DesignTokens.Spacing.lg)
}
