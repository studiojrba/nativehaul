import SwiftUI

/// The floating sidebar (ADR 0037, round 2): a rounded panel with its own surface and shadow, inset from the window
/// edges and vertically centred, as tall as its nav items. It shows icons and expands to full labels while hovered,
/// floating over the page so the grid never reflows. In a short window it keeps every item reachable
/// (``FloatingRailMetrics``).
struct IconRailView: View {
    /// Selected destination.
    @Binding var selection: SidebarDestination?
    /// Library state for section counts.
    let libraryViewModel: LibraryViewModel
    @State private var isExpanded = false
    @State private var availableHeight: CGFloat = 0
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        let metrics = FloatingRailMetrics(
            available: availableHeight,
            content: contentHeight,
            preferredMargin: DesignTokens.FloatingRail.margin
        )
        panel(metrics)
            .padding(.vertical, metrics.verticalMargin)
            .frame(maxHeight: .infinity)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { availableHeight = $0 }
            .padding(.leading, DesignTokens.FloatingRail.margin)
    }

    private func panel(_ metrics: FloatingRailMetrics) -> some View {
        let shape = RoundedRectangle(cornerRadius: DesignTokens.FloatingRail.cornerRadius, style: .continuous)
        return ScrollView(.vertical) {
            items
                .padding(DesignTokens.Spacing.sm)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { contentHeight = $0 }
        }
        .scrollDisabled(!metrics.needsScroll)
        .scrollIndicators(metrics.needsScroll ? .automatic : .hidden)
        .frame(
            width: isExpanded ? DesignTokens.Rail.expandedWidth : DesignTokens.Rail.collapsedWidth,
            height: metrics.panelHeight
        )
        .clipShape(shape)
        .background {
            shape.fill(Theme.surface)
                .shadow(
                    color: Theme.panelShadow,
                    radius: DesignTokens.FloatingRail.shadowRadius,
                    y: DesignTokens.FloatingRail.shadowOffset
                )
        }
        .overlay { shape.strokeBorder(Theme.hairline) }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: DesignTokens.Motion.quick)) { isExpanded = hovering }
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
    IconRailView(selection: .constant(.library(.all)), libraryViewModel: AppEnvironment.preview.makeLibraryViewModel())
        .frame(height: DesignTokens.Layout.windowMinHeight)
        .background(Theme.canvas)
}
