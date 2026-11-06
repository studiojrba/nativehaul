import SwiftUI

/// Narrow icon rail that expands to full labels while hovered (Playnite-style).
///
/// The rail floats over the content when expanded, so the grid never reflows on hover.
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
                    Divider().padding(.vertical, DesignTokens.Spacing.xs)
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
        .background(Theme.surface)
        .shadow(radius: isExpanded ? DesignTokens.Rail.shadowRadius : DesignTokens.Spacing.none)
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
