import SwiftUI

/// A recipe's verdict, shown instead of the Download button when it blocks installing.
struct CompatibilityVerdictView: View {
    /// The verdict.
    let verdict: CompatibilityVerdict

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Label(verdict.rating.displayName, systemImage: verdict.rating.blocksInstall ? "nosign" : "checkmark.seal")
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(verdict.rating.blocksInstall ? Theme.danger : Theme.primaryText)
            Text(verdict.reason)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    CompatibilityVerdictView(verdict: CompatibilityVerdict(rating: .antiCheatBlocked, reason: "BattlEye blocks it."))
        .padding(DesignTokens.Spacing.lg)
}
