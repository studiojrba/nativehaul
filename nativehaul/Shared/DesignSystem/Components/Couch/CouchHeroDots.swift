import SwiftUI

/// The hero's dots at couch size (spec §4.1): 10pt circles of `ink` 20%, the active one an accent pill 40pt wide that
/// glows at night.
struct CouchHeroDots: View {
    /// Number of slides.
    let count: Int
    /// The active slide.
    let index: Int
    /// The couch scale.
    let scale: CouchScale

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: scale(CouchLayout.Hero.dotGap)) {
            ForEach(0 ..< count, id: \.self) { slide in
                Capsule()
                    .fill(slide == index ? Theme.accent : Theme.ink.opacity(HeroTiming.dotOpacity))
                    .frame(
                        width: scale(slide == index ? CouchLayout.Hero.activeDot : CouchLayout.Hero.dot),
                        height: scale(CouchLayout.Hero.dot)
                    )
                    .accentGlow(slide == index)
            }
        }
        .animation(reduceMotion ? nil : Motion.settle(), value: index)
        .accessibilityElement()
        .accessibilityLabel("Game \(index + 1) of \(count)")
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        CouchHeroDots(count: 5, index: 1, scale: scale).padding(DesignTokens.Spacing.xl)
    }
}
