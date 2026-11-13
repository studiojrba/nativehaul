import SwiftUI

/// The frost card couch overlays share (spec §3.7 Resume/Close): `paper` 30% over a blur, then a card `min(720, 80vw)`
/// wide, radius 48, padding 48, `elev-lg`, rising in. A header with the cover (no title text), an eyebrow and the
/// game's
/// short title; an optional line; up to two buttons; and the overlay's own prompts.
struct CouchOverlayCard: View {
    /// The game, if the card is about one.
    let game: Game?
    /// "Paused", "Closing", "Still running".
    let eyebrow: String
    /// The big line (the game's short title).
    let title: String
    /// An explanation under the header, if any.
    var message: String?
    /// The buttons' labels (zero or two).
    var buttons: [String] = []
    /// The focused button.
    var focusedButton = 0
    /// The prompts under the buttons.
    var prompts: [CouchPrompt] = []
    /// Glyph set.
    let family: ControllerFamily
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.Paused

    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            Theme.paper.opacity(Metrics.backdropOpacity)
            card.riseIn()
        }
        .ignoresSafeArea()
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }

    private var card: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if let message {
                Text(message)
                    .font(Typeface.sans(scale(Metrics.body)))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, scale(Metrics.promptsTop))
            }
            if !buttons.isEmpty {
                HStack(spacing: scale(Metrics.buttonGap)) {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { offset, label in
                        CouchOverlayButton(title: label, isFocused: offset == focusedButton, scale: scale)
                    }
                }
                .padding(.top, scale(Metrics.buttonsTop))
            }
            if !prompts.isEmpty {
                HStack(spacing: scale(CouchLayout.PromptBar.gap)) {
                    ForEach(prompts) { CouchPromptView(prompt: $0, family: family, scale: scale) }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, scale(Metrics.promptsTop))
            }
        }
        .padding(scale(Metrics.padding))
        .frame(width: min(scale(Metrics.width), scale.width(Metrics.widthShare)))
        .frostedGlass(in: RoundedRectangle(cornerRadius: scale(Metrics.radius), style: .continuous))
        .elevation(.large)
    }

    private var header: some View {
        HStack(spacing: scale(Metrics.headerGap)) {
            if let game {
                ArtworkFill(path: game.coverImagePath, title: "", placeholderSize: scale(Metrics.eyebrow))
                    .frame(
                        width: scale(Metrics.coverWidth),
                        height: scale(Metrics.coverWidth) / CouchLayout.Tile.aspect
                    )
                    .clipShape(RoundedRectangle(cornerRadius: scale(Metrics.coverRadius), style: .continuous))
                    .elevation(.regular)
            }
            VStack(alignment: .leading, spacing: scale(Metrics.titleTop)) {
                Eyebrow(eyebrow, size: scale(Metrics.eyebrow))
                Text(title)
                    .font(Typeface.display(scale(Metrics.title)))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(Metrics.titleLines)
                    .minimumScaleFactor(DesignTokens.Typography.minimumScale)
            }
        }
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        CouchOverlayCard(
            game: Game(title: "Lantern Coast"),
            eyebrow: "Paused",
            title: "Lantern Coast",
            buttons: ["Resume", "Close game"],
            prompts: [CouchPrompt(buttons: [.select], label: "Select"), CouchPrompt(buttons: [.back], label: "Resume")],
            family: .nintendo,
            scale: scale
        )
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
    }
}
