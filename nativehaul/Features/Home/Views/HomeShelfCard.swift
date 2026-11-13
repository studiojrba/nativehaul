import SwiftUI

/// One game on a curated shelf (Make `Row` card): its cover (real art, else the drawn cover) with an optional frosted
/// badge, then its name and genre.
struct HomeShelfCard: View {
    /// The game.
    let game: Game
    /// The badge on its cover, if any.
    let badge: String?
    /// Opens its Detail.
    let open: () -> Void

    @State private var isHovered = false

    private typealias Metrics = ShellLayout.HomeShelves

    var body: some View {
        Button(action: open) {
            VStack(alignment: .leading, spacing: 0) {
                Color.clear
                    .aspectRatio(ShellLayout.Library.coverAspect, contentMode: .fit)
                    .overlay {
                        ArtworkFill(
                            path: game.coverImagePath,
                            title: game.title,
                            placeholderSize: Metrics.coverEm * ShellLayout.DrawnCover.titleEm,
                            studio: game.developer
                        )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: Metrics.coverRadius, style: .continuous))
                    .elevation(isHovered ? .large : .regular)
                    .overlay(alignment: .topTrailing) {
                        if let badge {
                            Text(badge)
                                .font(Typeface.sans(TypeStyle.Size.micro, weight: .medium))
                                .foregroundStyle(Theme.ink)
                                .padding(.horizontal, Metrics.badgeHorizontal)
                                .padding(.vertical, Metrics.badgeVertical)
                                .frostedGlass()
                                .elevation(.small)
                                .padding(Metrics.badgeInset)
                        }
                    }
                Text(game.title)
                    .font(Typeface.sans(TypeStyle.Size.label, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(DesignTokens.Lines.single)
                    .padding(.top, Metrics.nameTop)
                if let genre = game.genres.first {
                    Text(genre)
                        .font(Typeface.sans(TypeStyle.Size.small))
                        .foregroundStyle(Theme.inkMute)
                        .lineLimit(DesignTokens.Lines.single)
                }
            }
            .frame(width: Metrics.cardWidth, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressButtonStyle())
        .onHover { isHovered = $0 }
        .animation(Motion.settle(), value: isHovered)
    }
}

#Preview {
    AppearancePreviewPair {
        HomeShelfCard(game: Game(title: "Lantern Coast"), badge: "2025") {}
            .padding(DesignTokens.Spacing.xl)
    }
}
