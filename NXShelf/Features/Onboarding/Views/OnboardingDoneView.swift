import SwiftUI

/// What was set up, what was skipped and where to find it later.
struct OnboardingDoneView: View {
    /// Per-module results.
    let outcomes: [OnboardingOutcome]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            Text("You're all set").font(DesignTokens.Typography.display)
                .tracking(DesignTokens.Typography.displayTracking)
            Text("NX Shelf keeps finding installed games, syncing and filling in artwork by itself.")
                .foregroundStyle(Theme.secondaryText)
            ForEach(outcomes) { outcome in
                if outcome.isSetUp {
                    Label("\(outcome.module.title) — set up", systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Theme.success)
                } else {
                    Label {
                        Text("\(outcome.module.title) — skipped. Find it later in \(outcome.module.laterLocation).")
                    } icon: {
                        Image(systemName: "circle.dashed")
                    }
                    .foregroundStyle(Theme.secondaryText)
                }
            }
            Text("Run setup again any time from Settings → General.")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(Theme.secondaryText)
        }
    }
}

#Preview {
    OnboardingDoneView(outcomes: [
        OnboardingOutcome(module: .findGames, isSetUp: true),
        OnboardingOutcome(module: .emulators, isSetUp: false),
    ])
    .padding(DesignTokens.Spacing.xl)
}
