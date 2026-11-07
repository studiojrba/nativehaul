import SwiftUI

/// Narrow icon rail that expands to full labels while hovered (Playnite-style).
///
/// The rail floats over the content when expanded (it is an overlay; the content is inset by the collapsed width
/// only), so the grid never reflows or jitters on hover. It sits on the sidebar surface — dimmer than the canvas —
/// with a hairline edge instead of a shadow (ADR 0025).
struct IconRailView: View {
    /// Selected destination.
    @Binding var selection: SidebarDestination?
    /// Library state for section counts.
    let libraryViewModel: LibraryViewModel
    @State private var isExpanded = false

    var body: some View {
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
            Spacer()
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(width: isExpanded ? DesignTokens.Rail.expandedWidth : DesignTokens.Rail.collapsedWidth)
        .frame(maxHeight: .infinity)
        .background(Theme.sidebar)
        .overlay(alignment: .trailing) {
            Rectangle().fill(Theme.hairline).frame(width: DesignTokens.Stroke.hairline)
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: DesignTokens.Motion.quick)) { isExpanded = hovering }
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
}
