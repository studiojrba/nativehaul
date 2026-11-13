import SwiftUI

/// Builds until its 0.1.0 redesign lands (a later phase): the existing build dashboard, clear of the nav island and the
/// top bar.
struct BuildsPage: View {
    /// The build queue.
    let viewModel: NXNativeViewModel

    var body: some View {
        NXNativeDashboardView(viewModel: viewModel)
            .clipShape(RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous))
            .padding(.leading, ShellLayout.Chrome.islandClearance)
            .padding(.top, ShellLayout.Chrome.topBarClearance)
            .padding([.trailing, .bottom], DesignTokens.Spacing.lg)
    }
}

#Preview {
    let environment = AppEnvironment.preview
    BuildsPage(viewModel: environment.makeNXNativeViewModel {})
        .environment(environment)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
