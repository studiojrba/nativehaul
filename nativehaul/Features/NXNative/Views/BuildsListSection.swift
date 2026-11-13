import SwiftUI

/// A list on the Builds page ("Building", "Fresh out"; spec §3.4): a tracked heading over its rows. Empty lists are
/// left out by the caller.
struct BuildsListSection: View {
    /// The heading.
    let title: String
    /// The builds.
    let jobs: [BuildJob]
    /// The page state.
    let viewModel: BuildsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.Builds.listHeadingGap) {
            Text(title.uppercased())
                .font(Typeface.sans(TypeStyle.Size.caption, weight: .medium))
                .tracking(TypeStyle.tracking(em: TypeStyle.Eyebrow.listTrackingEm, size: TypeStyle.Size.caption))
                .foregroundStyle(Theme.inkMute)
                .accessibilityAddTraits(.isHeader)
            VStack(spacing: ShellLayout.Builds.rowGap) {
                ForEach(jobs) { job in
                    BuildsListRow(
                        job: job,
                        title: viewModel.shortTitle(for: job),
                        coverPath: viewModel.coverPath(for: job),
                        isSelected: viewModel.selectedJob?.id == job.id
                    ) { viewModel.select(job) }
                }
            }
        }
    }
}

#Preview {
    let environment = AppEnvironment.preview
    let viewModel = BuildsViewModel(
        queue: environment.makeNXNativeViewModel {},
        library: { [] },
        paletteExtractor: MockGamePaletteExtractor()
    )
    BuildsListSection(title: "Building", jobs: [], viewModel: viewModel)
        .padding(DesignTokens.Spacing.xl)
}
