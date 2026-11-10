import SwiftUI

/// A single headline number with a caption.
struct StatTile: View {
    /// Caption.
    let title: String
    /// Value text.
    let value: String
    /// Optional SF Symbol.
    var symbolName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if let symbolName {
                    Image(systemName: symbolName)
                }
                Text(title)
            }
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(Theme.secondaryText)
            Text(value).font(DesignTokens.Typography.statValue)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(minWidth: DesignTokens.Layout.statTileMinWidth, maxWidth: .infinity, alignment: .leading)
        .surfaceCard()
    }
}

#Preview {
    StatTile(title: "Backlog", value: "42", symbolName: "tray.full")
        .padding(DesignTokens.Spacing.lg)
}
