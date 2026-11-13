import SwiftUI

/// One search result (spec §3.0): a 36×48 cover thumb, the title at 14pt medium and the studio at 12pt `ink-mute`.
struct SearchResultRow: View {
    /// The game.
    let game: Game
    /// Opens it.
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: ShellLayout.Chrome.innerGap) {
                ArtworkFill(
                    path: game.coverImagePath,
                    title: game.title,
                    placeholderSize: TypeStyle.Size.micro,
                    showsTitle: false
                )
                .frame(width: ShellLayout.TopBar.resultThumb.width, height: ShellLayout.TopBar.resultThumb.height)
                .clipShape(RoundedRectangle(
                    cornerRadius: ShellLayout.TopBar.resultThumbRadius,
                    style: .continuous
                ))
                VStack(alignment: .leading, spacing: 0) {
                    Text(game.title)
                        .font(Typeface.sans(TypeStyle.Size.body, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(DesignTokens.Lines.single)
                    if let studio = game.developer, !studio.isEmpty {
                        Text(studio)
                            .font(Typeface.sans(TypeStyle.Size.caption))
                            .foregroundStyle(Theme.inkMute)
                            .lineLimit(DesignTokens.Lines.single)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(ShellLayout.Chrome.resultPadding)
            .background {
                if isHovered {
                    RoundedRectangle(cornerRadius: ShellLayout.Chrome.resultRadius, style: .continuous)
                        .fill(Theme.surface.opacity(ShellLayout.Chrome.resultHoverOpacity))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .pointerStyle(.link)
        .onHover { isHovered = $0 }
    }
}

#Preview {
    AppearancePreviewPair {
        SearchResultRow(game: Game(title: "Lantern Coast")) {}
            .frame(width: ShellLayout.TopBar.searchMaxWidth)
            .padding(DesignTokens.Spacing.xl)
    }
}
