import SwiftUI

/// "Hey! I'm NX Shelf." — what it does, then the trust block, before any setup is asked for.
struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
            (Text("Hey! I'm ") + Text("NX Shelf").foregroundStyle(Theme.accent) + Text("."))
                .font(DesignTokens.Typography.hero)
                .tracking(DesignTokens.Typography.displayTracking)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Label("Your whole game library in one place.", systemImage: "square.grid.2x2")
                Label("Your Switch ports and emulated games on one shelf. Click and play.", systemImage: "play.circle")
                Label("Hours played, progress and guides for every game.", systemImage: "chart.bar")
            }
            .font(DesignTokens.Typography.title)
            .foregroundStyle(Theme.primaryText)
            OnboardingTrustBlock()
        }
    }
}

#Preview {
    OnboardingWelcomeView().padding(DesignTokens.Spacing.xl)
}
