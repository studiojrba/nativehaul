import SwiftUI

/// Couch focus (spec §3.7): an accent ring `width` thick, `offset` outside the element, the gap filled with `paper`
/// (CSS `ring-offset`). The design system owns the accent treatment; couch screens ask for it here.
struct CouchFocusRing<S: InsettableShape>: ViewModifier {
    /// Whether the ring shows.
    let isVisible: Bool
    /// The element's outline.
    let shape: S
    /// Ring thickness.
    let width: CGFloat
    /// Gap between the element and the ring.
    let offset: CGFloat

    func body(content: Content) -> some View {
        content.overlay {
            if isVisible {
                ZStack {
                    if offset > 0 {
                        shape.inset(by: -offset).strokeBorder(Theme.paper, lineWidth: offset)
                    }
                    shape.inset(by: -offset - width).strokeBorder(Theme.accent, lineWidth: width)
                }
                .allowsHitTesting(false)
            }
        }
    }
}

extension View {
    /// Draws couch's focus ring around `shape` while `isVisible`.
    func couchFocusRing(
        _ isVisible: Bool,
        in shape: some InsettableShape,
        width: CGFloat,
        offset: CGFloat
    ) -> some View {
        modifier(CouchFocusRing(isVisible: isVisible, shape: shape, width: width, offset: offset))
    }
}

#Preview {
    AppearancePreviewPair {
        RoundedRectangle(cornerRadius: CouchLayout.Tile.radius, style: .continuous)
            .fill(Theme.surface)
            .frame(width: CouchLayout.Shelves.tileWidth, height: CouchLayout.Shelves.tileWidth)
            .couchFocusRing(
                true,
                in: RoundedRectangle(cornerRadius: CouchLayout.Tile.radius, style: .continuous),
                width: CouchLayout.Tile.ringWidth,
                offset: CouchLayout.Tile.ringOffset
            )
            .padding(KitMetrics.Spacing.page)
    }
}
