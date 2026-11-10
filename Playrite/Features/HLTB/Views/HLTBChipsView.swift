import SwiftUI

/// Main Story / Main Story+ / Completionist chips, labelled "HLTB estimate". Quiet and monochrome (ADR 0025):
/// estimates are labelled, never colour-coded like ratings.
struct HLTBChipsView: View {
    /// Chips to show.
    let chips: [HLTBChip]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(chips) { chip in
                    VStack(spacing: DesignTokens.Spacing.xxs) {
                        Text(chip.title).font(DesignTokens.Typography.caption)
                            .foregroundStyle(Theme.secondaryText)
                            .lineLimit(DesignTokens.Lines.single)
                            .minimumScaleFactor(DesignTokens.Typography.minimumScale)
                        Text(chip.value).font(DesignTokens.Typography.figures).fontWeight(.semibold)
                            .foregroundStyle(Theme.primaryText)
                            .monospacedDigit()
                            .lineLimit(DesignTokens.Lines.single)
                            .minimumScaleFactor(DesignTokens.Typography.minimumScale)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .padding(.horizontal, DesignTokens.Spacing.xs)
                    .surfaceCard(cornerRadius: DesignTokens.Radius.md, fill: Theme.canvas)
                }
            }
            TagLabel(text: HLTBEstimate.label, symbolName: PlaytimeSource.hltbEstimate.symbolName)
        }
    }
}

#Preview {
    HLTBChipsView(chips: HLTBChip.chips(for: nil))
        .frame(width: DesignTokens.Details.rightRailWidth)
        .padding(DesignTokens.Spacing.lg)
}
