import SwiftUI

/// Main Story / Main Story+ / Completionist chips, labelled "HLTB estimate".
struct HLTBChipsView: View {
    /// Chips to show.
    let chips: [HLTBChip]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(chips) { chip in
                    VStack(spacing: DesignTokens.Spacing.xxs) {
                        Text(chip.title).font(DesignTokens.Typography.captionEmphasis)
                        Text(chip.value).font(DesignTokens.Typography.monospacedSmall)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(DesignTokens.Spacing.xs)
                    .background(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                            .fill(Theme.estimate.opacity(DesignTokens.Opacity.subtle))
                    )
                }
            }
            TagLabel(text: HLTBEstimate.label, symbolName: PlaytimeSource.hltbEstimate.symbolName, tint: Theme.estimate)
        }
    }
}

#Preview {
    HLTBChipsView(chips: HLTBChip.chips(for: nil))
        .frame(width: DesignTokens.Details.rightRailWidth)
        .padding(DesignTokens.Spacing.lg)
}
