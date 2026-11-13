import SwiftUI

/// A percentage in the accent on a faint accent pill (Make `bg-accent/15 px-3 py-1.5 text-[12px] text-accent`).
struct AccentPercentPill: View {
    /// 0…100.
    let percent: Int

    var body: some View {
        Text("\(percent)%")
            .font(Typeface.sans(TypeStyle.Size.caption).monospacedDigit())
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, ShellLayout.OnboardingBuild.pillHorizontal)
            .padding(.vertical, ShellLayout.OnboardingBuild.pillVertical)
            .background(Capsule().fill(Theme.accent.opacity(ShellLayout.OnboardingBuild.percentFill)))
    }
}

#Preview {
    AccentPercentPill(percent: 42).padding(DesignTokens.Spacing.lg)
}
