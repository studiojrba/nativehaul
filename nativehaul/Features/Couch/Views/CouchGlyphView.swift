import SwiftUI

/// One controller button in a prompt (spec §3.7): a 40pt `ink` circle with `paper` text (16pt semibold), or a 56×40
/// rounded rectangle for shoulders and triggers.
struct CouchGlyphView: View {
    /// The glyph.
    let glyph: CouchGlyph
    /// The couch scale.
    let scale: CouchScale

    private typealias Metrics = CouchLayout.PromptBar

    var body: some View {
        label
            .font(Typeface.sans(scale(Metrics.glyphText), weight: .semibold))
            .foregroundStyle(Theme.paper)
            .frame(width: scale(glyph.isWide ? Metrics.wideGlyph : Metrics.glyph), height: scale(Metrics.glyph))
            .background {
                if glyph.isWide {
                    RoundedRectangle(cornerRadius: scale(Metrics.wideRadius), style: .continuous).fill(Theme.ink)
                } else {
                    Circle().fill(Theme.ink)
                }
            }
            .accessibilityHidden(true)
    }

    @ViewBuilder private var label: some View {
        if let symbol = glyph.symbol {
            Image(systemName: symbol)
        } else {
            Text(glyph.text ?? "")
        }
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.md) {
            ForEach(CouchButton.allCases, id: \.self) { button in
                CouchGlyphView(glyph: ControllerGlyphs.glyph(for: button, family: .nintendo), scale: scale)
            }
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
