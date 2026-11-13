import SwiftUI

/// A horizontal shelf (spec §4.2): no visible scrollbar, full-bleed to its container with the first card aligned by
/// `leadingInset`, shadow room inside the scrollport, mouse click-drag with momentum, native wheel/trackpad scrolling
/// (which cancels a glide), and bare chevrons that page 90% of the visible width and fade at the ends.
///
/// Cards inside should use ``ShelfCardButton`` so a drag never counts as a click.
struct ShelfScroller<Content: View>: View {
    /// Space before the first card (lines it up with the content column).
    let leadingInset: CGFloat
    /// Space after the last card.
    let trailingInset: CGFloat
    /// Gap between cards.
    var gap: CGFloat = KitMetrics.Spacing.roomy
    /// Left chevron's inset from the shelf's edge.
    var chevronLeading: CGFloat = KitMetrics.Chevron.padding
    /// Right chevron's inset from the shelf's edge.
    var chevronTrailing: CGFloat = KitMetrics.Chevron.padding
    /// The cards.
    @ViewBuilder let content: () -> Content

    @State private var controller = ShelfGlideController()

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: gap) {
                content()
            }
            .padding(.leading, leadingInset)
            .padding(.trailing, trailingInset)
            .padding(.top, ShelfPhysics.shadowPaddingTop)
            .padding(.bottom, ShelfPhysics.shadowPaddingBottom)
        }
        .scrollIndicators(.never)
        .scrollPosition($controller.position)
        .onScrollGeometryChange(for: ShelfMetrics.self) { geometry in
            ShelfMetrics(
                offset: geometry.contentOffset.x,
                maxOffset: max(0, geometry.contentSize.width - geometry.containerSize.width),
                containerWidth: geometry.containerSize.width
            )
        } action: { _, metrics in
            controller.update(metrics: metrics, leadingInset: leadingInset, trailingInset: trailingInset)
        }
        .onScrollPhaseChange { _, phase in
            if phase == .interacting || phase == .decelerating {
                controller.userScrolled()
            }
        }
        .simultaneousGesture(drag)
        .environment(\.shelfController, controller)
        .environment(\.isShelfDragging, controller.isDragging)
        .padding(.top, -ShelfPhysics.shadowPaddingTop)
        .padding(.bottom, -ShelfPhysics.shadowPaddingBottom)
        .overlay(alignment: .leading) {
            ChevronButton(direction: .leading, isVisible: controller.arrows.leading) { controller.page(-1) }
                .padding(.leading, chevronLeading)
        }
        .overlay(alignment: .trailing) {
            ChevronButton(direction: .trailing, isVisible: controller.arrows.trailing) { controller.page(1) }
                .padding(.trailing, chevronTrailing)
        }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: ShelfPhysics.dragThreshold, coordinateSpace: .global)
            .onChanged { controller.dragChanged(translation: $0.translation.width, at: $0.time) }
            .onEnded { controller.dragEnded(at: $0.time) }
    }
}

#Preview {
    AppearancePreviewPair {
        ShelfScroller(
            leadingInset: ShellLayout.Content.leadingInset,
            trailingInset: ShellLayout.Content.trailingInset
        ) {
            ForEach(0 ..< 8, id: \.self) { _ in
                ShelfCardButton {} label: {
                    RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous)
                        .fill(Theme.cream)
                        .frame(width: DesignTokens.Cover.stripWidth, height: DesignTokens.Cover.stripWidth)
                        .elevation(.regular)
                }
            }
        }
    }
}
