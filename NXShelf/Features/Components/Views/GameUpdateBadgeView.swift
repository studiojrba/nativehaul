import SwiftUI

/// Shows a game's update badge, if it has one. Display only — the user's own sources do the updating.
struct GameUpdateBadgeView: View {
    /// The badge.
    let badge: GameUpdateBadge?

    var body: some View {
        if let badge {
            Label(badge.text, systemImage: "arrow.down.circle")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.info)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
        GameUpdateBadgeView(badge: .switchUpdateAvailable(latest: "1.2.0"))
        GameUpdateBadgeView(badge: .switchUpdateAvailable(latest: "1.3.0"))
    }
    .frame(width: DesignTokens.Details.rightRailWidth)
    .padding(DesignTokens.Spacing.lg)
}
