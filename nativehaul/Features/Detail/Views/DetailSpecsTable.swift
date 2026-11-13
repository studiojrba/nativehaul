import SwiftUI

/// Detail's specs table (spec §3.3): label left in `ink-mute`, value right, hairlines above the table and under each
/// row. Only rows with a real value are given to it.
struct DetailSpecsTable: View {
    /// The rows.
    let rows: [DetailSpecRow]

    var body: some View {
        VStack(spacing: 0) {
            HairlineDivider()
            ForEach(rows) { row in
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.lg) {
                    Text(row.label)
                        .font(Typeface.sans(TypeStyle.Size.body))
                        .foregroundStyle(Theme.inkMute)
                    Spacer(minLength: 0)
                    value(row)
                        .foregroundStyle(Theme.ink)
                        .multilineTextAlignment(.trailing)
                        .textSelection(.enabled)
                }
                .padding(.vertical, ShellLayout.Detail.specRowVertical)
                HairlineDivider()
            }
        }
    }

    @ViewBuilder
    private func value(_ row: DetailSpecRow) -> some View {
        switch row.style {
        case .plain:
            Text(row.value).font(Typeface.sans(TypeStyle.Size.label))
        case let .status(isReady):
            StatusDot(text: row.value, isReady: isReady).font(Typeface.sans(TypeStyle.Size.label))
        case .monospaced:
            Text(row.value)
                .font(.system(size: TypeStyle.Size.small, design: .monospaced))
                .tracking(TypeStyle.tracking(em: ShellLayout.GameCase.footerTrackingEm, size: TypeStyle.Size.small))
        }
    }
}

#Preview {
    AppearancePreviewPair {
        DetailSpecsTable(rows: [
            DetailSpecRow(label: "Playtime", value: "11h 40m"),
            DetailSpecRow(label: "Build status", value: "Ready to play", style: .status(isReady: true)),
            DetailSpecRow(label: "Game ID", value: "0100ABCD00010000", style: .monospaced),
        ])
        .frame(width: ShellLayout.Detail.descriptionMaxWidth)
        .padding(DesignTokens.Spacing.xl)
    }
}
