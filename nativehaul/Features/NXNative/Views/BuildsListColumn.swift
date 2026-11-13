import SwiftUI

/// The Builds page's left column (spec §3.4): "Builds", "In the oven", how many are on the go, Add a build and the
/// tools, then "Building" and "Fresh out" (each only when it has builds).
struct BuildsListColumn: View {
    /// The page state.
    let viewModel: BuildsViewModel
    /// Opens Add a build.
    let addBuild: () -> Void
    /// Opens the known issues list.
    let openKnownIssues: () -> Void
    /// Opens the engine picker.
    let chooseEngine: () -> Void

    private typealias Metrics = ShellLayout.Builds

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 0) {
                Eyebrow("Builds")
                DisplayHeadline(
                    lead: "In the oven",
                    size: TypeStyle.DisplaySize.page,
                    lineHeight: Metrics.titleLineHeight
                )
                .padding(.top, Metrics.titleGap)
                Text(viewModel.subtitle)
                    .font(Typeface.sans(TypeStyle.Size.label))
                    .foregroundStyle(Theme.inkSoft)
                    .padding(.top, Metrics.titleGap)
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Button("Add a build", systemImage: "plus", action: addBuild)
                        .buttonStyle(SurfacePillButtonStyle(isCompact: true))
                    BuildsToolsMenu(
                        viewModel: viewModel.queue,
                        openKnownIssues: openKnownIssues,
                        chooseEngine: chooseEngine
                    )
                }
                .padding(.top, Metrics.titleGap)
                if !viewModel.building.isEmpty {
                    BuildsListSection(title: "Building", jobs: viewModel.building, viewModel: viewModel)
                        .padding(.top, Metrics.listGap)
                }
                if !viewModel.freshOut.isEmpty {
                    BuildsListSection(title: "Fresh out", jobs: viewModel.freshOut, viewModel: viewModel)
                        .padding(.top, Metrics.listGap)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, Metrics.listLeading)
            .padding(.trailing, Metrics.listTrailing)
            .padding(.top, Metrics.listTop)
            .padding(.bottom, Metrics.listBottom)
        }
        .scrollIndicators(.never)
    }
}

#Preview {
    let environment = AppEnvironment.preview
    BuildsListColumn(
        viewModel: BuildsViewModel(
            queue: environment.makeNXNativeViewModel {},
            library: { [] },
            paletteExtractor: MockGamePaletteExtractor()
        ),
        addBuild: {},
        openKnownIssues: {},
        chooseEngine: {}
    )
    .frame(
        width: ShellLayout.Builds.listMinWidth + ShellLayout.Builds.listLeading,
        height: DesignTokens.Layout.windowMinHeight
    )
}
