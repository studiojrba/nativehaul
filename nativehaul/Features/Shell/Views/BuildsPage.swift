import SwiftUI

/// Builds inside the shell (spec §3.4): the page, focused on the title Detail's build link asked for.
struct BuildsPage: View {
    /// The page state.
    let viewModel: BuildsViewModel
    /// The shell (the focus request).
    let shell: ShellViewModel

    var body: some View {
        BuildsScreen(viewModel: viewModel, focusTitleID: shell.buildsFocusTitleID) { shell.buildsFocusTaken() }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    BuildsPage(
        viewModel: BuildsViewModel(
            queue: environment.makeNXNativeViewModel {},
            library: { [] },
            paletteExtractor: MockGamePaletteExtractor()
        ),
        shell: ShellViewModel(makeLaunch: environment.makeGameLaunchViewModel(for:))
    )
    .environment(environment)
    .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
