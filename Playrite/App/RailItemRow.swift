import SwiftUI

/// One rail button: icon always, label and count only when expanded.
struct RailItemRow: View {
    /// Item to show.
    let item: RailItem
    /// Library count badge, if any.
    let count: Int?
    /// Whether the rail is expanded.
    let isExpanded: Bool
    /// Whether this item is selected.
    let isSelected: Bool
    /// Called on click.
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: item.symbolName)
                    .foregroundStyle(isSelected ? Theme.accent : Theme.secondaryText)
                    .frame(width: DesignTokens.Rail.iconWidth)
                if isExpanded {
                    Text(item.title)
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(isSelected ? Theme.primaryText : Theme.secondaryText)
                        .lineLimit(DesignTokens.Lines.single)
                    Spacer(minLength: DesignTokens.Spacing.sm)
                    if let count {
                        Text("\(count)")
                            .font(DesignTokens.Typography.figuresSmall)
                            .foregroundStyle(Theme.tertiaryText)
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.Rail.itemHeight, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                    .fill(isSelected ? Theme.accentSoft : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(item.title)
        .accessibilityLabel(Text(item.title))
    }
}

#Preview {
    VStack {
        RailItemRow(
            item: RailItem(destination: .stats, title: "Stats & Badges", symbolName: "chart.bar"),
            count: nil, isExpanded: true, isSelected: true
        ) {}
        RailItemRow(
            item: RailItem(destination: .steam, title: "Steam", symbolName: "cloud"),
            count: 12, isExpanded: false, isSelected: false
        ) {}
    }
    .frame(width: DesignTokens.Rail.expandedWidth)
    .padding(DesignTokens.Spacing.lg)
}
