import SwiftUI

/// A grid cell: cover art, title, subtitle and an optional trailing accessory.
struct CoverCard<Accessory: View>: View {
    /// Primary text.
    let title: String
    /// Secondary text.
    let subtitle: String
    /// Local cover image path.
    let imagePath: String?
    /// Small view shown under the subtitle (e.g. a status tag).
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            CoverArtView(imagePath: imagePath, title: title)
            Text(title)
                .font(DesignTokens.Typography.headline)
                .lineLimit(DesignTokens.Lines.single)
            Text(subtitle)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(DesignTokens.Lines.single)
            accessory()
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    CoverCard(title: "Tideborn", subtitle: "Switch (native port)", imagePath: nil) {
        TagLabel(text: "Backlog", symbolName: "tray.full", tint: Theme.info)
    }
    .frame(width: DesignTokens.Cover.minWidth)
    .padding(DesignTokens.Spacing.lg)
}
