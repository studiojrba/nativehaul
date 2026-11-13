import SwiftUI

/// Onboarding's top bar (spec §3.6): the n. mark and wordmark (clear of the real window buttons), the progress dots in
/// the middle, and "Skip the tour" on the right.
struct OnboardingTopBar: View {
    /// The current step.
    let step: Int
    /// Skips the tour.
    let skip: () -> Void

    @State private var isSkipHovered = false

    var body: some View {
        ZStack {
            HStack(spacing: ShellLayout.Onboarding.markGap) {
                AppMark()
                    .frame(width: ShellLayout.Onboarding.markSize, height: ShellLayout.Onboarding.markSize)
                    .elevation(.small)
                Text(AppInfo.productName)
                    .font(Typeface.sans(ShellLayout.Onboarding.wordmarkSize, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Button("Skip the tour", action: skip)
                    .buttonStyle(.plain)
                    .font(Typeface.sans(TypeStyle.Size.small))
                    .foregroundStyle(isSkipHovered ? Theme.ink : Theme.inkSoft)
                    .padding(.horizontal, ShellLayout.Onboarding.skipHorizontal)
                    .padding(.vertical, ShellLayout.Onboarding.skipVertical)
                    .background {
                        if isSkipHovered {
                            Capsule().fill(Theme.surface.opacity(ShellLayout.Onboarding.skipHoverOpacity))
                        }
                    }
                    .contentShape(Capsule())
                    .onHover { isSkipHovered = $0 }
                    .pointerStyle(.link)
            }
            OnboardingProgressDots(step: step)
        }
        .padding(.leading, ShellLayout.Onboarding.markLeading)
        .padding(.trailing, ShellLayout.Onboarding.topBarTrailing)
        .padding(.top, ShellLayout.Onboarding.topBarTop)
    }
}

#Preview {
    AppearancePreviewPair {
        OnboardingTopBar(step: 1) {}.padding(.bottom, DesignTokens.Spacing.xl)
    }
}
