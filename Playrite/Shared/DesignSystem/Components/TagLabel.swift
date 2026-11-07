import SwiftUI

/// A small tinted capsule label (status, source, badge state).
struct TagLabel: View {
    /// Label text.
    let text: String
    /// Optional SF Symbol.
    var symbolName: String?
    /// Tint colour from ``Theme``.
    var tint: Color = Theme.secondaryText

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xxs) {
            if let symbolName {
                Image(systemName: symbolName)
            }
            Text(text)
        }
        .font(DesignTokens.Typography.captionEmphasis)
        .foregroundStyle(tint)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xxs)
        .background(Capsule().fill(Theme.surface))
        .overlay(Capsule().strokeBorder(Theme.hairline))
    }
}

#Preview {
    TagLabel(text: "HLTB estimate", symbolName: "clock", tint: Theme.estimate)
        .padding(DesignTokens.Spacing.lg)
}
