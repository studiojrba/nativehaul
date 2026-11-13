import SwiftUI

/// A Resume/Close overlay button (spec §3.7): 96pt tall, radius 30, 28pt text. Focused: scale 1.04 on `surface` with a
/// 5pt accent ring 4pt out (plus an ember glow at night); unfocused: `surface` 50%.
struct CouchOverlayButton: View {
    /// The label.
    let title: String
    /// Whether it has focus.
    let isFocused: Bool
    /// The couch scale.
    let scale: CouchScale

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = CouchLayout.Paused

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: scale(Metrics.buttonRadius), style: .continuous)
        Text(title)
            .font(Typeface.sans(scale(Metrics.buttonText)))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: scale(Metrics.buttonHeight))
            .background { shape.fill(isFocused ? Theme.surface : Theme.surface.opacity(Metrics.unfocusedOpacity)) }
            .couchFocusRing(
                isFocused,
                in: shape,
                width: scale(CouchLayout.Tile.ringWidth),
                offset: scale(Metrics.ringOffset)
            )
            .shadow(isFocused && colorScheme == .dark ? CouchFocusTokens.nightButtonGlow : .none)
            .scaleEffect(isFocused ? Metrics.focusScale : 1)
            .animation(reduceMotion ? nil : Motion.settle(), value: isFocused)
            .accessibilityAddTraits(isFocused ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        HStack(spacing: scale(CouchLayout.Paused.buttonGap)) {
            CouchOverlayButton(title: "Resume", isFocused: true, scale: scale)
            CouchOverlayButton(title: "Close game", isFocused: false, scale: scale)
        }
        .frame(width: scale(CouchLayout.Paused.width))
        .padding(KitMetrics.Spacing.page)
    }
}
