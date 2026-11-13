import SwiftUI

/// One prompt: its glyphs, then its label in `ink-soft` (spec §3.7).
struct CouchPromptView: View {
    /// The prompt.
    let prompt: CouchPrompt
    /// Which controller's glyphs to draw.
    let family: ControllerFamily
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.PromptBar

    var body: some View {
        HStack(spacing: scale(Metrics.labelGap)) {
            HStack(spacing: scale(Metrics.glyphGap)) {
                ForEach(Array(prompt.buttons.enumerated()), id: \.offset) { item in
                    CouchGlyphView(glyph: ControllerGlyphs.glyph(for: item.element, family: family), scale: scale)
                }
            }
            Text(prompt.label)
                .font(Typeface.sans(scale(Metrics.label)))
                .foregroundStyle(Theme.inkSoft)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(prompt.label)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            CouchPromptView(prompt: CouchPrompt(buttons: [.select], label: "Play"), family: .nintendo, scale: scale)
            CouchPromptView(
                prompt: CouchPrompt(buttons: [.previousGame, .nextGame], label: "Switch game"),
                family: .xbox,
                scale: scale
            )
            CouchPromptView(prompt: CouchPrompt(buttons: [.select], label: "Play"), family: .playStation, scale: scale)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
