import SwiftUI

/// HLTB bar with the player's own time beside it (ADR 0039, item 5). The estimates are marked on one track and
/// labelled "HLTB estimate"; the player's time is drawn against them from its largest real source, and every real
/// source is listed separately, never added together.
struct HLTBBarView: View {
    /// The bar, or `nil` when no estimate is cached.
    let bar: HLTBBar?
    /// The player's real playtime, per source.
    let playtime: PlaytimeBreakdown

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.xl) {
            if let bar {
                track(bar).frame(maxWidth: .infinity)
            }
            yourTime.frame(maxWidth: bar == nil ? .infinity : nil, alignment: .leading)
        }
    }

    private func track(_ bar: HLTBBar) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.placeholder)
                    Capsule().fill(Theme.secondaryText)
                        .frame(width: proxy.size.width * bar.playedFraction)
                    ForEach(bar.markers) { marker in
                        Rectangle().fill(Theme.primaryText)
                            .frame(width: DesignTokens.DetailColumn.markerWidth)
                            .offset(x: proxy.size.width * marker.position - DesignTokens.DetailColumn.markerWidth)
                    }
                }
            }
            .frame(height: DesignTokens.DetailColumn.barHeight)
            HStack(spacing: DesignTokens.Spacing.md) {
                ForEach(bar.markers) { marker in
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                        Text(marker.category.chipName).font(DesignTokens.Typography.caption)
                            .foregroundStyle(Theme.secondaryText)
                        Text(DurationFormatting.compact(seconds: marker.seconds))
                            .font(DesignTokens.Typography.figures).fontWeight(.semibold).monospacedDigit()
                    }
                }
            }
            TagLabel(text: HLTBEstimate.label, symbolName: PlaytimeSource.hltbEstimate.symbolName)
        }
    }

    private var yourTime: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text("Your time").font(DesignTokens.Typography.caption).foregroundStyle(Theme.secondaryText)
            if playtime.entries.isEmpty {
                Text("Not played yet").foregroundStyle(Theme.secondaryText)
            } else {
                ForEach(playtime.entries) { entry in
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(DurationFormatting.compact(seconds: entry.seconds))
                            .font(DesignTokens.Typography.figures).fontWeight(.semibold).monospacedDigit()
                        PlaytimeSourceTag(source: entry.source)
                    }
                }
            }
        }
    }
}

#Preview {
    HLTBBarView(bar: nil, playtime: PlaytimeBreakdown(secondsBySource: [.steamSynced: 7200]))
        .padding(DesignTokens.Spacing.lg)
}
