import SwiftUI

/// The closing scene (note 6, Make `ClosingScene`): the n. mark with an ember check, "Your shelf is ready.", the mode
/// it
/// opens in, and a reminder that Settings keeps the door open (including this tour).
struct ClosingScene: View {
    /// The mode chosen.
    let mode: AppMode?

    var body: some View {
        VStack(spacing: 0) {
            AppMark()
                .frame(width: ShellLayout.OnboardingBuild.closingMark, height: ShellLayout.OnboardingBuild.closingMark)
                .elevation(.large)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "checkmark")
                        .font(.system(size: ShellLayout.OnboardingBuild.checkIcon, weight: .bold))
                        .foregroundStyle(Theme.onAccent)
                        .frame(
                            width: ShellLayout.OnboardingBuild.checkBadge,
                            height: ShellLayout.OnboardingBuild.checkBadge
                        )
                        .background { EmberFill(shape: Circle()) }
                        .offset(x: ShellLayout.OnboardingBuild.checkOffset, y: ShellLayout.OnboardingBuild.checkOffset)
                }
            Text("Your shelf is ready.")
                .font(Typeface.display(ShellLayout.OnboardingBuild.closingTitle))
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.center)
                .padding(.top, ShellLayout.OnboardingBuild.closingTitleTop)
            Text(mode == .couch ? "Opening in Couch mode." : "Opening in Desktop mode.")
                .font(Typeface.sans(TypeStyle.Size.label))
                .foregroundStyle(Theme.inkSoft)
                .padding(.top, ShellLayout.OnboardingBuild.closingSubTop)
            settingsCard.padding(.top, ShellLayout.OnboardingBuild.closingCardTop)
        }
        .padding(.horizontal, ShellLayout.OnboardingBuild.closingHorizontal)
        .padding(.vertical, ShellLayout.OnboardingBuild.closingVertical)
        .frame(maxWidth: ShellLayout.OnboardingBuild.closingMaxWidth)
        .tutorialPanel(padding: DesignTokens.Spacing.none, radius: ShellLayout.OnboardingBuild.closingRadius)
    }

    private var settingsCard: some View {
        HStack(spacing: ShellLayout.OnboardingBuild.closingCardGap) {
            AccentGlyph(symbol: "sparkles", size: ShellLayout.OnboardingBuild.closingCardIcon)
            VStack(alignment: .leading, spacing: ShellLayout.OnboardingBuild.closingCardSubTop) {
                Text("Settings keeps the door open")
                    .font(Typeface.sans(TypeStyle.Size.body, weight: .medium))
                    .foregroundStyle(Theme.ink)
                Text("Change anything, or take this tour again.")
                    .font(Typeface.sans(TypeStyle.Size.caption))
                    .foregroundStyle(Theme.inkMute)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, ShellLayout.OnboardingBuild.closingCardHorizontal)
        .padding(.vertical, ShellLayout.OnboardingBuild.closingCardVertical)
        .background(
            RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.closingCardRadius, style: .continuous)
                .fill(Theme.paper2)
        )
    }
}

#Preview {
    AppearancePreviewPair {
        ClosingScene(mode: .couch).padding(DesignTokens.Spacing.xl)
    }
}
