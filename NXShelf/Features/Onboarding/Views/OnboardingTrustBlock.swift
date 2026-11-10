import SwiftUI

/// The good news, shown before any setup: open source, no account, no telemetry, no weird permissions.
struct OnboardingTrustBlock: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("The good news first").font(DesignTokens.Typography.title)
            Label("Completely open source.", systemImage: "chevron.left.forwardslash.chevron.right")
            Label("No account to create.", systemImage: "person.crop.circle.badge.xmark")
            Label("No telemetry. Nothing about you or your games is sent anywhere.", systemImage: "eye.slash")
            Label(
                "No weird permissions. NX Shelf never asks for Accessibility or Screen Recording access.",
                systemImage: "lock.shield"
            )
            Label(
                "It only looks in folders you point it at, plus the standard places games install to "
                    + "(~/Switch/Games, and your emulators' own folders).",
                systemImage: "folder"
            )
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.success.opacity(DesignTokens.Opacity.subtle), in: RoundedRectangle(
            cornerRadius: DesignTokens.Radius.lg
        ))
    }
}

#Preview {
    OnboardingTrustBlock().padding(DesignTokens.Spacing.xl)
}
