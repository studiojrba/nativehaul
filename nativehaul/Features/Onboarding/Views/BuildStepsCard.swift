import SwiftUI

/// "nxnative · how it works" (Make `BuildTutorial` intro): four step cards — one folder, Begin build, one tidy spot,
/// launch.
struct BuildStepsCard: View {
    private struct Step: Identifiable {
        let symbol: String
        let title: String
        let note: String
        var id: String {
            title
        }
    }

    private static let steps = [
        Step(symbol: "folder", title: "One folder", note: "Base games, updates and DLC"),
        Step(symbol: "sparkles", title: "Begin build", note: "Build and verify"),
        Step(symbol: "internaldrive", title: "Keep it tidy", note: "One build folder"),
        Step(symbol: "play", title: "Launch", note: "Mouse or controller"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.OnboardingBuild.contentTop) {
            Eyebrow("nxnative · how it works")
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: ShellLayout.OnboardingBuild.stepGap),
                    GridItem(.flexible()),
                ],
                spacing: ShellLayout.OnboardingBuild.stepGap
            ) {
                ForEach(Array(Self.steps.enumerated()), id: \.element.id) { index, step in
                    card(step, number: index + 1)
                        .riseIn(delay: Double(index) * ShellLayout.Onboarding.actionStagger)
                }
            }
        }
        .tutorialPanel(padding: ShellLayout.OnboardingBuild.panelPaddingCompact)
        .frame(maxWidth: ShellLayout.OnboardingBuild.panelMaxWidth)
    }

    private func card(_ step: Step, number: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.stepRadius, style: .continuous)
        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: ShellLayout.OnboardingBuild.stepChipGap) {
                Image(systemName: step.symbol)
                    .font(.system(size: ShellLayout.OnboardingBuild.stepIcon))
                    .foregroundStyle(Theme.ink)
                    .frame(width: ShellLayout.OnboardingBuild.stepChip, height: ShellLayout.OnboardingBuild.stepChip)
                    .background(
                        RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.stepChipRadius, style: .continuous)
                            .fill(Theme.cream)
                    )
                Text(String(format: "%02d", number))
                    .font(Typeface.sans(TypeStyle.Size.caption).monospacedDigit())
                    .foregroundStyle(Theme.inkMute)
            }
            Text(step.title)
                .font(Typeface.sans(ShellLayout.OnboardingBuild.stepTitle, weight: .medium))
                .foregroundStyle(Theme.ink)
                .padding(.top, ShellLayout.OnboardingBuild.stepTitleTop)
            Text(step.note)
                .font(Typeface.sans(TypeStyle.Size.small))
                .foregroundStyle(Theme.inkMute)
                .padding(.top, ShellLayout.OnboardingBuild.stepNoteTop)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(ShellLayout.OnboardingBuild.stepPadding)
        .background { Color.clear.frostedGlass(in: shape) }
        .elevation(.small)
    }
}

#Preview {
    AppearancePreviewPair {
        BuildStepsCard().padding(DesignTokens.Spacing.xl)
    }
}
