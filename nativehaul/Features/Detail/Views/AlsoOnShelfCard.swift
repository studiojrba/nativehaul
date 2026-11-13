import SwiftUI

/// One "Also on your shelf" cover (spec §3.3): 3:4 art, radius 22, `elev-sm` lifting to `elev` on hover, and the short
/// title under it.
struct AlsoOnShelfCard: View {
    /// The game.
    let game: Game
    /// Opens its Detail.
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: ShellLayout.Detail.relatedTitleTop) {
                Color.clear
                    .aspectRatio(ShellLayout.Detail.relatedAspect, contentMode: .fit)
                    .overlay { ArtworkFill(path: game.coverImagePath, title: game.title) }
                    .clipShape(RoundedRectangle(cornerRadius: ShellLayout.Detail.relatedRadius, style: .continuous))
                    .elevation(isHovered ? .regular : .small)
                Text(ShortTitle.make(from: game.title))
                    .font(Typeface.sans(TypeStyle.Size.body, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(DesignTokens.Lines.title)
            }
        }
        .buttonStyle(PressButtonStyle())
        .onHover { isHovered = $0 }
        .animation(Motion.settle(), value: isHovered)
    }
}

#Preview {
    AppearancePreviewPair {
        AlsoOnShelfCard(game: Game(title: "Lantern Coast")) {}
            .frame(width: DesignTokens.Cover.minWidth)
            .padding(DesignTokens.Spacing.xl)
    }
}
