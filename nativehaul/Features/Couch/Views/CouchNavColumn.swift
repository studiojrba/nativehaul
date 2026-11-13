import SwiftUI

/// The sidebar's couch equivalent (ADR 0058, undesigned — derived from the nav island): a frost panel on the left with
/// Home, Library, Builds and Settings at 10-foot scale. It slides in when Left reaches it from a screen's first
/// column, so the mirrored screens keep their full width otherwise. The current screen's icon is in the accent.
struct CouchNavColumn: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    private typealias Metrics = CouchLayout.Nav

    var body: some View {
        let scale = viewModel.scale
        VStack(alignment: .leading, spacing: scale(Metrics.gap)) {
            ForEach(Array(CouchFocusState.navItems.enumerated()), id: \.element.id) { offset, item in
                row(item, isFocused: offset == viewModel.state.navIndex, scale: scale)
            }
        }
        .padding(scale(Metrics.padding))
        .frame(width: scale(Metrics.width), alignment: .leading)
        .frostedGlass(in: RoundedRectangle(cornerRadius: scale(Metrics.radius), style: .continuous))
        .elevation(.large)
        .padding(.leading, scale(Metrics.leading))
        .frame(maxHeight: .infinity, alignment: .center)
    }

    private func row(_ item: NavItem, isFocused: Bool, scale: CouchScale) -> some View {
        CouchNavRow(
            symbol: item.symbolName,
            title: item.title,
            isCurrent: item.screen == viewModel.state.screen.islandScreen,
            isFocused: isFocused,
            scale: scale
        )
    }
}

#Preview {
    let viewModel = CouchViewModel.preview
    viewModel.state.area = .nav
    return AppearancePreviewPair {
        CouchNavColumn(viewModel: viewModel)
            .frame(height: DesignTokens.Layout.windowMinHeight)
    }
}
