import SwiftUI

/// Earned or locked badge with progress and evidence.
struct BadgeTile: View {
    /// Result to render.
    let result: BadgeResult

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Image(systemName: result.definition.symbolName)
                .font(DesignTokens.Typography.title)
                .frame(width: DesignTokens.Layout.badgeSize, height: DesignTokens.Layout.badgeSize)
                .foregroundStyle(result.isEarned ? Theme.accent : Theme.secondaryText)
                .background(Circle().fill(Theme.placeholder))
            Text(result.definition.title).font(DesignTokens.Typography.headline)
            Text(result.definition.criteria)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(DesignTokens.Lines.summary)
            if result.isEarned {
                TagLabel(
                    text: result.evidence.map { "Earned · \($0)" } ?? "Earned",
                    symbolName: "checkmark",
                    tint: Theme.success
                )
            } else {
                ProgressView(value: Double(result.progress), total: Double(result.definition.target))
                Text("\(result.progress) / \(result.definition.target)")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg).fill(Theme.surface))
        .opacity(result.isEarned ? 1 : DesignTokens.Opacity.overlay)
    }
}

#Preview {
    BadgeTile(result: BadgeResult(definition: BadgeCatalog.all[0], progress: 1, evidence: "Ember Protocol"))
        .frame(width: DesignTokens.Layout.statTileMinWidth)
        .padding(DesignTokens.Spacing.lg)
}
