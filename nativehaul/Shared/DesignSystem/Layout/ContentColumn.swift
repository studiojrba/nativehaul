import CoreGraphics

/// The shared content column (spec §3 intro) expressed as insets from a full-width container: a column at most 1280pt
/// wide, centred, with 128pt on the left (clearing the nav island) and 56pt on the right. Full-bleed rows (shelves) use
/// these insets so their first card lines up with the headings.
struct ContentColumn: Equatable, Sendable {
    /// Leading inset from the container's edge.
    let leading: CGFloat
    /// Trailing inset from the container's edge.
    let trailing: CGFloat

    private static let sides: CGFloat = 2

    /// The insets for a container `width` wide.
    init(width: CGFloat) {
        let margin = max(0, (width - ShellLayout.Content.maxWidth) / Self.sides)
        leading = margin + ShellLayout.Content.leadingInset
        trailing = margin + ShellLayout.Content.trailingInset
    }

    /// The column's usable width inside a container `width` wide.
    func contentWidth(in width: CGFloat) -> CGFloat {
        max(0, width - leading - trailing)
    }

    /// The width of one of `count` cards across the column, `gap` apart (spec §3.1: three Continue cards at rest).
    func cardWidth(in width: CGFloat, count: Int, gap: CGFloat) -> CGFloat {
        guard count > 0 else { return 0 }
        return max(0, (contentWidth(in: width) - gap * CGFloat(count - 1)) / CGFloat(count))
    }
}
