import SwiftUI

/// The six progress dots (spec §3.6): done at `ink` 50%, the current one stretched to 28pt, upcoming at 15%, moving on
/// the house easing over 700ms.
struct OnboardingProgressDots: View {
    /// The current step, 0…5.
    let step: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: ShellLayout.Onboarding.dotGap) {
            ForEach(0 ..< OnboardingBeat.stepCount, id: \.self) { index in
                Capsule()
                    .fill(Theme.ink.opacity(opacity(for: index)))
                    .frame(
                        width: index == step ? ShellLayout.Onboarding.dotActiveWidth : ShellLayout.Onboarding.dotSize,
                        height: ShellLayout.Onboarding.dotSize
                    )
            }
        }
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.rise), value: step)
        .accessibilityElement()
        .accessibilityLabel("Step \(step + 1) of \(OnboardingBeat.stepCount)")
    }

    private func opacity(for index: Int) -> Double {
        if index == step {
            return 1
        }
        return index < step ? ShellLayout.Onboarding.dotDoneOpacity : ShellLayout.Onboarding.dotUpcomingOpacity
    }
}

#Preview {
    AppearancePreviewPair {
        OnboardingProgressDots(step: 2).padding(DesignTokens.Spacing.xl)
    }
}
