import SwiftUI

/// The screen background wash (spec §3.0 `Wash`): up to three radial gradients — `60%×50% at 15% 10%`,
/// `50%×50% at 90% 20%` and `60%×60% at 60% 100%` — each fading to clear at 70% of its reach. Changing the colours
/// crossfades over 1000ms.
struct WashBackground: View {
    /// Raw colours (game tones, lifts), used when ``slots`` is `nil`.
    private let colors: [RGBA]
    /// Theme wash slots, resolved per appearance.
    private let slots: [WashSlot]?
    /// Crossfade duration when the colours change.
    private let crossfade: Double
    /// The CSS extents are radii; frames are diameters.
    private static let diameterPerRadius: CGFloat = 2

    @Environment(\.themeTokens) private var tokens
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// A wash of raw colours, in gradient order (game tones, lifts).
    init(colors: [RGBA], crossfade: Double = ShellLayout.Wash.crossfade) {
        self.colors = colors
        slots = nil
        self.crossfade = crossfade
    }

    /// A wash of theme slots, in gradient order; follows the appearance.
    init(slots: [WashSlot], crossfade: Double = ShellLayout.Wash.crossfade) {
        colors = []
        self.slots = slots
        self.crossfade = crossfade
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(resolved.prefix(ShellLayout.Wash.centers.count).enumerated()), id: \.offset) { item in
                    gradient(item.element, index: item.offset, in: proxy.size)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .animation(reduceMotion ? nil : .easeInOut(duration: crossfade), value: resolved)
    }

    private var resolved: [RGBA] {
        slots.map { $0.map(tokens.wash) } ?? colors
    }

    /// One ellipse: its frame spans twice the CSS radii, centred on the CSS position.
    private func gradient(_ color: RGBA, index: Int, in size: CGSize) -> some View {
        let extent = ShellLayout.Wash.extents[index]
        let center = ShellLayout.Wash.centers[index]
        return Ellipse()
            .fill(EllipticalGradient(
                stops: [
                    .init(color: color.color, location: 0),
                    .init(color: color.opacity(0).color, location: ShellLayout.Wash.fadeStop),
                ],
                center: .center
            ))
            .frame(
                width: extent.width * size.width * Self.diameterPerRadius,
                height: extent.height * size.height * Self.diameterPerRadius
            )
            .position(x: center.x * size.width, y: center.y * size.height)
    }
}

#Preview {
    AppearancePreviewPair {
        WashBackground(slots: [.sky, .butter, .blush])
            .frame(height: ShellLayout.Library.washHeight / 2)
    }
}
