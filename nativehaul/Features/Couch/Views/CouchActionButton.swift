import SwiftUI

/// A couch button (Detail's Play and Favourite): a capsule, ember for the primary action, `surface` otherwise. Focused,
/// it scales up and wears the accent ring.
struct CouchActionButton: View {
    /// The label.
    let title: String
    /// SF Symbol.
    let symbol: String
    /// Ember (Play) or `surface`.
    let isPrimary: Bool
    /// Whether it has focus.
    let isFocused: Bool
    /// The couch scale.
    let scale: CouchScale

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = CouchLayout.Detail

    var body: some View {
        HStack(spacing: scale(CouchLayout.PromptBar.labelGap)) {
            Image(systemName: symbol)
            Text(title)
        }
        .font(Typeface.sans(scale(Metrics.buttonText), weight: .medium))
        .foregroundStyle(isPrimary ? Theme.onAccent : Theme.ink)
        .padding(.horizontal, scale(Metrics.buttonPadding))
        .frame(height: scale(Metrics.buttonHeight))
        .background {
            if isPrimary {
                EmberFill(shape: Capsule())
            } else {
                Capsule().fill(Theme.surface)
            }
        }
        .elevation(.regular)
        .couchFocusRing(
            isFocused,
            in: Capsule(),
            width: scale(CouchLayout.Tile.ringWidth),
            offset: scale(CouchLayout.Paused.ringOffset)
        )
        .scaleEffect(isFocused ? Metrics.focusScale : 1)
        .animation(reduceMotion ? nil : Motion.settle(), value: isFocused)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.xl) {
            CouchActionButton(title: "Play", symbol: "play.fill", isPrimary: true, isFocused: true, scale: scale)
            CouchActionButton(title: "Favourite", symbol: "heart", isPrimary: false, isFocused: false, scale: scale)
        }
        .padding(KitMetrics.Spacing.page)
    }
}
