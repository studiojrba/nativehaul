import SwiftUI

/// The bottom bar of button prompts, drawn for the connected controller (ADR 0052).
struct TVPromptBar: View {
    /// Prompts to show.
    let prompts: [TVPrompt]
    /// The controller family the glyphs follow.
    let family: ControllerFamily
    /// Screen metrics.
    let metrics: TVMetrics

    var body: some View {
        HStack(spacing: metrics.doubleGap) {
            Spacer()
            ForEach(prompts) { prompt in
                HStack(spacing: metrics.halfGap) {
                    TVGlyphView(
                        glyph: ControllerGlyphs.glyph(for: prompt.action, family: family),
                        size: metrics.bodySize
                    )
                    Text(prompt.label).font(metrics.bodyFont)
                }
            }
        }
        .foregroundStyle(Theme.primaryText)
    }
}

#Preview {
    TVPromptBar(
        prompts: [TVPrompt(action: .confirm, label: "Play"), TVPrompt(action: .back, label: "Back")],
        family: .nintendo,
        metrics: TVMetrics(size: DesignTokens.TVMode.previewScreen)
    )
    .padding(DesignTokens.Spacing.xl)
}
