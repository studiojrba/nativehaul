import SwiftUI

/// A game that is running right now, with a live elapsed timer.
struct ActiveSessionRow: View {
    /// Game title.
    let title: String
    /// Session start.
    let startedAt: Date

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "record.circle").foregroundStyle(Theme.danger)
            Text(title).font(DesignTokens.Typography.headline)
            Spacer(minLength: DesignTokens.Spacing.none)
            Text(startedAt, style: .timer).font(DesignTokens.Typography.figures)
            PlaytimeSourceTag(source: .macTracked)
        }
    }
}

#Preview {
    ActiveSessionRow(title: "Tideborn", startedAt: .now.addingTimeInterval(-600))
        .padding(DesignTokens.Spacing.lg)
}
