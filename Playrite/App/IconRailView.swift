import SwiftUI

/// The floating sidebar (ADR 0037, round 2): a rounded panel with its own surface and shadow, inset from the window
/// edges and vertically centred, as tall as its nav items. It shows icons and expands to full labels while hovered,
/// floating over the page so the grid never reflows. In a short window it keeps every item reachable
/// (``FloatingRailMetrics``). Hovering never moves it vertically: the expansion is width-only, to the right
/// (round 2.1).
struct IconRailView: View {
    /// Selected destination.
    @Binding var selection: SidebarDestination?
    /// Whether the panel shows labels (true while hovered). Owned by the shell, so tests can drive it.
    @Binding var isExpanded: Bool
    /// Library state for section counts.
    let libraryViewModel: LibraryViewModel
    @State private var availableHeight: CGFloat = 0
    @State private var restingContentHeight: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        let metrics = FloatingRailMetrics(
            available: availableHeight,
            content: restingContentHeight,
            preferredMargin: DesignTokens.FloatingRail.margin
        )
        panel(metrics)
            .padding(.vertical, metrics.verticalMargin)
            .frame(maxHeight: .infinity)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { availableHeight = $0 }
            .padding(.leading, DesignTokens.FloatingRail.margin)
    }

    /// Hover changes the width only (round 2.1): the height and vertical position come from the resting layout, and
    /// only the width frame animates, anchored on the left edge.
    private func panel(_ metrics: FloatingRailMetrics) -> some View {
        let shape = RoundedRectangle(cornerRadius: DesignTokens.FloatingRail.cornerRadius, style: .continuous)
        return content(scrolls: metrics.needsScroll)
            .frame(height: metrics.panelHeight, alignment: .top)
            .frame(
                width: isExpanded ? DesignTokens.Rail.expandedWidth : DesignTokens.Rail.collapsedWidth,
                alignment: .leading
            )
            .clipShape(shape)
            .background {
                // Frosted glass with warm cream over the blur (ADR 0040), and a soft shadow instead of a border.
                shape.fill(.ultraThinMaterial)
                    .overlay { shape.fill(Theme.surface.opacity(DesignTokens.Light.frostTintOpacity)) }
                    .shadow(
                        color: Theme.panelShadow,
                        radius: DesignTokens.FloatingRail.shadowRadius,
                        y: DesignTokens.FloatingRail.shadowOffset
                    )
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: DesignTokens.Motion.quick), value: isExpanded)
            .onHover { isExpanded = $0 }
    }

    /// The nav items, in a scroll view only when the window is too short for them.
    @ViewBuilder private func content(scrolls: Bool) -> some View {
        if scrolls {
            ScrollView(.vertical) { paddedItems }
        } else {
            paddedItems
        }
    }

    /// Collapsed rows fit the panel exactly (icon plus row padding), so nothing re-centres as the width changes.
    private var paddedItems: some View {
        items
            .padding(.horizontal, DesignTokens.Spacing.xs)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                if !isExpanded || restingContentHeight == 0 {
                    restingContentHeight = height
                }
            }
    }

    private var items: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            ForEach(Array(RailItem.groups.enumerated()), id: \.offset) { index, group in
                if index > 0 {
                    Rectangle()
                        .fill(Theme.hairline)
                        .frame(height: DesignTokens.Stroke.hairline)
                        .padding(.vertical, DesignTokens.Spacing.sm)
                }
                ForEach(group) { item in
                    RailItemRow(
                        item: item,
                        count: count(for: item),
                        isExpanded: isExpanded,
                        isSelected: selection == item.destination
                    ) { selection = item.destination }
                }
            }
        }
    }

    private func count(for item: RailItem) -> Int? {
        if case let .library(section) = item.destination {
            return libraryViewModel.count(for: section)
        }
        return nil
    }
}

#Preview {
    IconRailView(
        selection: .constant(.library(.all)),
        isExpanded: .constant(true),
        libraryViewModel: AppEnvironment.preview.makeLibraryViewModel()
    )
    .frame(height: DesignTokens.Layout.windowMinHeight)
    .background(Theme.canvas)
}
