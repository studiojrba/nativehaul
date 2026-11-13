import SwiftUI

/// Continue playing (spec §3.1): Jump Back In ranks 2–4 on a full-bleed shelf whose first card lines up with the
/// content column; three cards fill the column at rest. Hidden when there is nothing to continue.
struct ContinueSection: View {
    /// Home's state.
    let viewModel: HomeViewModel
    /// The page width.
    let pageWidth: CGFloat
    /// Plays a game.
    let play: (Game) -> Void
    /// Opens a game's Detail.
    let open: (Game) -> Void

    var body: some View {
        let games = viewModel.continuing
        if !games.isEmpty {
            let column = ContentColumn(width: pageWidth)
            let cardWidth = column.cardWidth(
                in: pageWidth,
                count: ShellLayout.Continue.cardsAcross,
                gap: ShellLayout.Continue.gap
            )
            VStack(alignment: .leading, spacing: ShellLayout.Continue.shelfTop) {
                SectionHead(eyebrow: "Continue playing", title: "Still on the go")
                    .padding(.leading, column.leading)
                    .padding(.trailing, column.trailing)
                ShelfScroller(
                    leadingInset: column.leading,
                    trailingInset: column.trailing,
                    gap: ShellLayout.Continue.gap,
                    chevronLeading: ShellLayout.Continue.chevronLeading,
                    chevronTrailing: ShellLayout.Continue.chevronTrailing
                ) {
                    ForEach(Array(games.enumerated()), id: \.element.id) { offset, game in
                        ContinueCard(
                            game: game,
                            line: viewModel.continueLine(for: game),
                            width: cardWidth,
                            open: { open(game) },
                            play: { play(game) }
                        )
                        .riseIn(delay: Double(offset) * ShellLayout.Continue.stagger)
                    }
                }
            }
            .padding(.top, ShellLayout.Continue.sectionTop)
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    ContinueSection(
        viewModel: HomeViewModel(
            library: environment.makeLibraryViewModel(),
            paletteExtractor: MockGamePaletteExtractor()
        ),
        pageWidth: DesignTokens.Layout.windowMinWidth,
        play: { _ in },
        open: { _ in }
    )
}
