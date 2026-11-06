import SwiftUI

/// A job in the queue list.
struct BuildJobRow: View {
    /// The job.
    let job: BuildJob

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(job.title.name).font(DesignTokens.Typography.headline)
            HStack(spacing: DesignTokens.Spacing.sm) {
                TagLabel(text: job.status.displayName, tint: job.status.tint)
                Text(job.title.titleID).font(DesignTokens.Typography.monospacedSmall)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

#Preview {
    BuildJobRow(job: BuildJob(
        sourcePath: "/s/a.nsp",
        title: TitleInfo(titleID: "0100000000010000", name: "Tideborn", architecture: .bit64)
    ))
    .padding(DesignTokens.Spacing.lg)
}
