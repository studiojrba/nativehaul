import SwiftUI

/// The `rise` entrance (spec §2.8): from transparent, 14pt lower and 98% scale, settling over 700ms. Runs once on
/// appear; a plain fade under Reduce Motion.
struct RiseEntrance: ViewModifier {
    /// Delay before rising (stagger lists by index).
    let delay: Double

    @State private var hasRisen = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(hasRisen ? 1 : 0)
            .offset(y: hasRisen || reduceMotion ? 0 : Motion.Rise.offset)
            .scaleEffect(hasRisen || reduceMotion ? 1 : Motion.Rise.scale)
            .onAppear {
                withAnimation(Motion.rise(reduceMotion: reduceMotion).delay(delay)) { hasRisen = true }
            }
    }
}

extension View {
    /// Rises into place on appear, after `delay` seconds.
    func riseIn(delay: Double = 0) -> some View {
        modifier(RiseEntrance(delay: delay))
    }
}

#Preview {
    AppearancePreviewPair {
        Text("Risen")
            .font(Typeface.display(TypeStyle.DisplaySize.card))
            .foregroundStyle(Theme.ink)
            .riseIn()
            .padding(DesignTokens.Spacing.xxl)
    }
}
