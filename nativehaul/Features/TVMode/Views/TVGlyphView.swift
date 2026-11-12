import SwiftUI

/// One button glyph in a prompt: SF Symbols for controllers, a key cap for the keyboard.
struct TVGlyphView: View {
    /// What to draw.
    let glyph: TVGlyph
    /// Text size.
    let size: CGFloat

    var body: some View {
        switch glyph {
        case let .symbols(names):
            HStack(spacing: DesignTokens.Spacing.xxs) {
                ForEach(names, id: \.self) { Image(systemName: $0) }
            }
            .font(.system(size: size, weight: .semibold))
        case let .key(name):
            Text(name)
                .font(.system(size: size * DesignTokens.Typography.minimumScale, weight: .semibold, design: .rounded))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        }
    }
}

#Preview {
    HStack(spacing: DesignTokens.Spacing.lg) {
        TVGlyphView(glyph: ControllerGlyphs.glyph(for: .confirm, family: .nintendo), size: DesignTokens.TypeScale.hero)
        TVGlyphView(
            glyph: ControllerGlyphs.glyph(for: .shelves, family: .playStation),
            size: DesignTokens.TypeScale.hero
        )
        TVGlyphView(glyph: ControllerGlyphs.glyph(for: .confirm, family: .keyboard), size: DesignTokens.TypeScale.hero)
    }
    .padding(DesignTokens.Spacing.xl)
}
