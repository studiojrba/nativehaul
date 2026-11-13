import SwiftUI

/// A tappable card on a shelf: press feedback and the hand cursor, and it ignores the click that ends a drag
/// (spec §4.2). Outside a shelf it behaves like a plain pressable button.
struct ShelfCardButton<Label: View>: View {
    /// What a real click does.
    let action: () -> Void
    /// The card.
    @ViewBuilder let label: () -> Label

    @Environment(\.shelfController) private var controller

    var body: some View {
        Button {
            if controller?.allowsTap() ?? true {
                action()
            }
        } label: {
            label()
        }
        .buttonStyle(PressButtonStyle())
    }
}

#Preview {
    AppearancePreviewPair {
        ShelfCardButton {} label: {
            RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous)
                .fill(Theme.cream)
                .frame(width: DesignTokens.Cover.stripWidth, height: DesignTokens.Cover.stripWidth)
        }
        .padding(KitMetrics.Spacing.section)
    }
}
