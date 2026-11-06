import SwiftUI

/// One previewed merge: the surviving title, how many entries go, and what the survivor gains.
struct DuplicateGroupRow: View {
    /// Group to show.
    let group: DuplicateGroup

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(group.title).font(DesignTokens.Typography.headline)
            Text(group.detail)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
        }
    }
}

#Preview {
    DuplicateGroupRow(group: DuplicateGroup(
        survivorID: UUID(), title: "Tideborn", duplicateIDs: [UUID()], gains: ["tracked app", "3 sessions"]
    ))
    .padding(DesignTokens.Spacing.lg)
}
