import SwiftUI

/// Title for a content section, with optional trailing caption.
struct SectionHeader: View {
    /// Section title.
    let title: String
    /// Optional secondary text.
    var caption: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
            Text(title).font(DesignTokens.Typography.title)
            if let caption {
                Text(caption)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer(minLength: DesignTokens.Spacing.none)
        }
    }
}

#Preview {
    SectionHeader(title: "Playtime", caption: "by source")
        .padding(DesignTokens.Spacing.lg)
}
