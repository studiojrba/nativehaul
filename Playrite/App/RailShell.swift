import SwiftUI

/// The window layout (ADR 0037, round 2): one continuous page background across the whole window, sidebar area
/// included, with the floating sidebar over it. The page keeps the collapsed panel's width clear through a safe-area
/// inset, so backgrounds that ignore the safe area (the canvas, Home's ambient wash) run under the panel.
struct RailShell<Content: View>: View {
    /// Selected destination.
    @Binding var selection: SidebarDestination?
    /// Library state for section counts.
    let libraryViewModel: LibraryViewModel
    /// The page.
    @ViewBuilder let content: Content

    var body: some View {
        content
            .safeAreaInset(edge: .leading, spacing: DesignTokens.Spacing.none) {
                Color.clear.frame(width: DesignTokens.FloatingRail.reservedWidth)
            }
            .overlay(alignment: .leading) {
                IconRailView(selection: $selection, libraryViewModel: libraryViewModel)
            }
            .background(Theme.canvas)
    }
}

#Preview {
    RailShell(selection: .constant(.home), libraryViewModel: AppEnvironment.preview.makeLibraryViewModel()) {
        EmptyStateView(title: "Pick a section", symbolName: "sidebar.left")
    }
    .frame(width: DesignTokens.Layout.detailMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
