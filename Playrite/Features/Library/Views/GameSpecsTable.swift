import SwiftUI

/// The specs table (ADR 0039, item 7): small label on the left, value on the right, hairlines between. Only rows with
/// data are passed in, so there are no empty rows.
struct GameSpecsTable: View {
    /// Rows to show.
    let rows: [GameSpecRow]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.none) {
            ForEach(rows) { row in
                HairlineDivider()
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.lg) {
                    Text(row.label)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(Theme.secondaryText)
                        .frame(width: DesignTokens.DetailColumn.specLabelWidth, alignment: .leading)
                    Text(row.value)
                        .foregroundStyle(Theme.primaryText)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.vertical, DesignTokens.Spacing.md)
            }
            if !rows.isEmpty {
                HairlineDivider()
            }
        }
    }
}

#Preview {
    GameSpecsTable(rows: [
        GameSpecRow(label: "Developer", value: "Supergiant Games"),
        GameSpecRow(label: "Genres", value: "Action, Roguelike"),
    ])
    .padding(DesignTokens.Spacing.lg)
}
