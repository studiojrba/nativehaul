import SwiftUI

/// Real recorded hours per source. Sources are never summed together.
struct HoursBySourceView: View {
    /// One entry per source.
    let entries: [PlaytimeEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            SectionHeader(title: "Hours by Source", caption: "kept separate — never added together")
            if entries.isEmpty {
                Text("No playtime recorded yet.").foregroundStyle(Theme.secondaryText)
            }
            ForEach(entries) { entry in
                HStack(spacing: DesignTokens.Spacing.md) {
                    PlaytimeSourceTag(source: entry.source)
                    Text(DurationFormatting.compact(seconds: entry.seconds)).font(DesignTokens.Typography.figures)
                    Spacer(minLength: DesignTokens.Spacing.none)
                }
            }
        }
    }
}

#Preview {
    HoursBySourceView(entries: [
        PlaytimeEntry(source: .steamSynced, seconds: 360_000),
        PlaytimeEntry(source: .macTracked, seconds: 7200),
    ])
    .padding(DesignTokens.Spacing.lg)
}
