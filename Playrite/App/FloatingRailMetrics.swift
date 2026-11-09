import CoreGraphics

/// Where the floating sidebar sits in a window of a given height (ADR 0037, round 2).
///
/// The panel is as tall as its nav items and centred. When the window is short, the space above and below shrinks
/// first; then the panel grows to the full height; only when even that isn't enough does it scroll. Nav items are
/// never clipped off-screen.
struct FloatingRailMetrics: Equatable, Sendable {
    /// Space kept above and below the panel.
    let verticalMargin: CGFloat
    /// The panel's height.
    let panelHeight: CGFloat
    /// Whether the nav items need to scroll inside the panel.
    let needsScroll: Bool

    private static let edges: CGFloat = 2

    /// The layout for `available` height, nav content `content` tall, and a preferred margin of `preferredMargin`.
    init(available: CGFloat, content: CGFloat, preferredMargin: CGFloat) {
        let height = max(0, available)
        let spare = max(0, height - content)
        verticalMargin = min(max(0, preferredMargin), spare / Self.edges)
        panelHeight = min(max(0, content), height)
        needsScroll = content > height
    }
}
