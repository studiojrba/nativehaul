import SwiftUI

/// The build tutorial's slim stage bar (Make `BuildDemo`: 8pt pills 6pt apart on `paper-2`, 11pt names): finished
/// stages fill in `ink`, the current one in the accent to its progress.
struct CompactStageBar: View {
    /// The segments, in order.
    let segments: [StageSegment]

    var body: some View {
        HStack(alignment: .top, spacing: ShellLayout.OnboardingBuild.stagesGap) {
            ForEach(segments) { segment in
                VStack(alignment: .leading, spacing: ShellLayout.OnboardingBuild.stageLabelTop) {
                    Capsule()
                        .fill(Theme.paper2)
                        .overlay(alignment: .leading) {
                            GeometryReader { proxy in
                                Capsule()
                                    .fill(segment.role == .current ? Theme.accent : Theme.ink)
                                    .frame(width: proxy.size.width * segment.fill)
                            }
                        }
                        .clipShape(Capsule())
                        .frame(height: ShellLayout.OnboardingBuild.stageBar)
                    Text(segment.name)
                        .font(Typeface.sans(TypeStyle.Size.micro))
                        .foregroundStyle(segment.role == .current ? Theme.ink : Theme.inkMute)
                        .lineLimit(DesignTokens.Lines.single)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    CompactStageBar(segments: [
        StageSegment(name: "Found", fill: 1, role: .completed),
        StageSegment(name: "Prepare", fill: 0.4, role: .current),
        StageSegment(name: "Verify", fill: 0, role: .upcoming),
    ])
    .padding(DesignTokens.Spacing.lg)
}
