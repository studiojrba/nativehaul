import SwiftUI

/// Backlog HLTB estimate, labelled and kept apart from real hours.
struct BacklogEstimateView: View {
    /// Estimate to show.
    let estimate: HLTBBacklogEstimate

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(
                title: "Backlog Estimate",
                caption: "\(estimate.coveredGames) of \(estimate.backlogGames) backlog games have an estimate"
            )
            HStack(spacing: DesignTokens.Spacing.md) {
                PlaytimeSourceTag(source: .hltbEstimate)
                Text(DurationFormatting.compact(seconds: estimate.seconds)).font(DesignTokens.Typography.figures)
                Text("main story · not added to your hours").foregroundStyle(Theme.secondaryText)
            }
        }
    }
}

#Preview {
    BacklogEstimateView(estimate: HLTBBacklogEstimate(seconds: 180_000, coveredGames: 3, backlogGames: 5))
        .padding(DesignTokens.Spacing.lg)
}
