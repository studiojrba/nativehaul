import SwiftUI

/// Label/value list on the details rail.
struct GameInfoList: View {
    /// Rows to show.
    let rows: [GameInfoRow]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            ForEach(rows) { row in
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                    Text(row.label)
                        .font(DesignTokens.Typography.captionEmphasis)
                        .foregroundStyle(Theme.secondaryText)
                        .frame(width: DesignTokens.Details.infoLabelWidth, alignment: .leading)
                    Text(row.value)
                        .font(DesignTokens.Typography.figuresSmall)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

#Preview {
    GameInfoList(rows: GameInfoBuilder.rows(for: Game(title: "Tideborn", platform: .switchPort)))
        .frame(width: DesignTokens.Details.rightRailWidth)
        .padding(DesignTokens.Spacing.lg)
}
