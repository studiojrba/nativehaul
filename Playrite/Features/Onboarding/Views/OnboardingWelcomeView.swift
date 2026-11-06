import SwiftUI

/// "Hey! I'm Retriever." — what it does, then the trust block, before any setup is asked for.
struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xl) {
            Text("Hey! I'm Retriever.").font(DesignTokens.Typography.largeTitle)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Label("Your whole game library in one place.", systemImage: "square.grid.2x2")
                Label("Install and play — Mac, Steam, Windows games and Switch ports.", systemImage: "play.circle")
                Label("Hours played, progress and guides for every game.", systemImage: "chart.bar")
            }
            .font(DesignTokens.Typography.headline)
            OnboardingTrustBlock()
        }
    }
}

#Preview {
    OnboardingWelcomeView().padding(DesignTokens.Spacing.xl)
}
