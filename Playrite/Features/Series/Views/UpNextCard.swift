import SwiftUI

/// One card in the Up Next strip. Shows the series' own part label verbatim.
struct UpNextCard: View {
    /// Item to render.
    let item: UpNextItem

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            CoverArtView(imagePath: nil, title: item.title, width: DesignTokens.Cover.stripWidth)
            Text("Part \(item.partLabel)")
                .font(DesignTokens.Typography.monospacedSmall)
                .fontWeight(item.isNext ? .bold : .regular)
                .foregroundStyle(item.isNext ? Theme.primaryText : Theme.secondaryText)
            Text(item.title)
                .font(DesignTokens.Typography.caption)
                .lineLimit(DesignTokens.Lines.title)
            if let status = item.status {
                StatusTag(status: status)
            } else {
                TagLabel(text: "Not in library", symbolName: "questionmark.circle", tint: Theme.secondaryText)
            }
        }
        .frame(width: DesignTokens.Cover.stripWidth, alignment: .leading)
    }
}

#Preview {
    UpNextCard(item: UpNextItem(id: UUID(), partLabel: "2", title: "Lantern II", status: .backlog, isNext: true))
        .padding(DesignTokens.Spacing.lg)
}
