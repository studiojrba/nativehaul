import SwiftUI

/// Lists playtime per source. Deliberately shows no merged total (ADR 0006).
struct PlaytimeBreakdownView: View {
    /// Breakdown to render.
    let breakdown: PlaytimeBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Playtime", caption: "per source — never merged")
            if breakdown.isEmpty {
                Text("No playtime recorded yet.")
                    .foregroundStyle(Theme.secondaryText)
            } else {
                ForEach(breakdown.entries) { entry in
                    HStack(spacing: DesignTokens.Spacing.md) {
                        PlaytimeSourceTag(source: entry.source)
                        Text(DurationFormatting.compact(seconds: entry.seconds))
                            .font(DesignTokens.Typography.monospaced)
                        Spacer(minLength: DesignTokens.Spacing.none)
                    }
                }
            }
        }
    }
}

#Preview {
    PlaytimeBreakdownView(breakdown: PlaytimeBreakdown(secondsBySource: [.steamSynced: 7200, .hltbEstimate: 36000]))
        .padding(DesignTokens.Spacing.lg)
}
