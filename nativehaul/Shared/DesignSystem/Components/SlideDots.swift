import SwiftUI

/// Quiet slideshow dots (spec §3.4 Builds): active 24 × 6 `ink`, inactive 6 × 6 `ink` 25%, 8pt apart, 500ms
/// transitions; tapping a dot jumps to it.
struct SlideDots: View {
    /// Number of slides.
    let count: Int
    /// The showing slide.
    let index: Int
    /// Jumps to a slide.
    let select: (Int) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = ShellLayout.Builds

    var body: some View {
        HStack(spacing: Metrics.dotGap) {
            ForEach(0 ..< count, id: \.self) { slide in
                Button { select(slide) } label: {
                    Capsule()
                        .fill(slide == index ? Theme.ink : Theme.ink.opacity(Metrics.dotOpacity))
                        .frame(
                            width: slide == index ? Metrics.dotActiveWidth : Metrics.dotSize,
                            height: Metrics.dotSize
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .pointerStyle(.link)
                .accessibilityLabel("Screenshot \(slide + 1)")
                .accessibilityAddTraits(slide == index ? .isSelected : [])
            }
        }
        .animation(reduceMotion ? nil : Motion.settle(), value: index)
    }
}

#Preview {
    AppearancePreviewPair {
        SlideDots(count: 4, index: 1) { _ in }
            .padding(DesignTokens.Spacing.xl)
    }
}
