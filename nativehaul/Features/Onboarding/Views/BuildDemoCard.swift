import SwiftUI

/// "Then press Begin build" (note 11): a sped-up build running through the real stage names to 100%, its build log
/// filling in, on a loop. Illustration only; the stages are progress labels, never buttons.
struct BuildDemoCard: View {
    /// The game named on the card.
    let title: String
    /// Its cover, if any.
    let imagePath: String?

    @State private var started = Date.now
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.periodic(from: started, by: ShellLayout.OnboardingBuild.demoTick)) { timeline in
            content(BuildDemoTimeline(
                elapsed: reduceMotion ? ShellLayout.OnboardingBuild.demoRun : timeline.date.timeIntervalSince(started),
                runLength: ShellLayout.OnboardingBuild.demoRun,
                loopLength: ShellLayout.OnboardingBuild.demoLoop
            ))
        }
        .tutorialPanel()
        .frame(maxWidth: ShellLayout.OnboardingBuild.panelMaxWidth)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("An example build of \(title), running through each stage to Ready.")
    }

    private func content(_ demo: BuildDemoTimeline) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: ShellLayout.OnboardingBuild.demoHeaderGap) {
                ArtworkFill(path: imagePath, title: title, placeholderSize: TypeStyle.Size.micro, showsTitle: false)
                    .frame(
                        width: ShellLayout.OnboardingBuild.demoCover.width,
                        height: ShellLayout.OnboardingBuild.demoCover.height
                    )
                    .clipShape(RoundedRectangle(
                        cornerRadius: ShellLayout.OnboardingBuild.demoCoverRadius,
                        style: .continuous
                    ))
                    .elevation(.regular)
                VStack(alignment: .leading, spacing: ShellLayout.OnboardingBuild.demoTitleTop) {
                    Eyebrow("Example build")
                    Text(title)
                        .font(Typeface.display(ShellLayout.OnboardingBuild.demoTitle))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(DesignTokens.Lines.single)
                }
                Spacer(minLength: 0)
                AccentPercentPill(percent: demo.percent)
            }
            stages(demo).padding(.top, ShellLayout.OnboardingBuild.stagesTop)
            BuildLogPanel(lines: demo.lines, screen: .onboarding, isLive: !demo.isDone)
                .padding(.top, ShellLayout.OnboardingBuild.logTop)
        }
    }

    private func stages(_ demo: BuildDemoTimeline) -> some View {
        CompactStageBar(segments: PipelineStage.allCases.map { stage in
            let isCurrent = stage == demo.currentStage && !demo.isDone
            return StageSegment(
                name: stage.name,
                fill: demo.fill(of: stage),
                role: isCurrent ? .current : (demo.fill(of: stage) >= 1 ? .completed : .upcoming)
            )
        })
    }
}

#Preview {
    AppearancePreviewPair {
        BuildDemoCard(title: "Lantern Coast", imagePath: nil).padding(DesignTokens.Spacing.xl)
    }
}
