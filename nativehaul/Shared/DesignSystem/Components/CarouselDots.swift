import SwiftUI

/// The hero carousel's dots (spec §4.1): one per slide; inactive 6pt circles of `ink` 20% (40% on hover), the active
/// one an accent pill 24pt wide that glows at night. Transitions 500ms ease-settle. Tapping a dot jumps to it.
struct CarouselDots: View {
    /// Number of slides.
    let count: Int
    /// The active slide.
    let index: Int
    /// A VoiceOver label per dot.
    var label: (Int) -> String = { "Show slide \($0 + 1)" }
    /// Jumps to a slide.
    let select: (Int) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< count, id: \.self) { slide in
                CarouselDot(isActive: slide == index) { select(slide) }
                    .accessibilityLabel(label(slide))
                    .accessibilityAddTraits(slide == index ? .isSelected : [])
            }
        }
        .animation(reduceMotion ? nil : Motion.settle(), value: index)
    }
}

#Preview {
    AppearancePreviewPair {
        CarouselDots(count: 5, index: 1) { _ in }
            .padding(DesignTokens.Spacing.xl)
    }
}
