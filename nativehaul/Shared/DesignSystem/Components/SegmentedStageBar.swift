import SwiftUI

/// The Builds page's segmented progress bar (spec §3.4): one 12pt pill per stage, 6pt apart, on a sunken track
/// (`surface` 70% with an inset top shadow by day, `paper-2` 80% by night). Completed and upcoming segments fill in
/// `ink`; the current one fills in the accent (glowing at night) to its progress. Each stage's name sits under its
/// segment — the current one in medium `ink`, completed in `ink-soft`, upcoming in `ink-mute` — and the current stage's
/// explanation under that. Fills move over 300ms.
struct SegmentedStageBar: View {
    /// The segments, in order.
    let segments: [StageSegment]
    /// The line under the current stage.
    var explanation: String?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = ShellLayout.Builds

    var body: some View {
        HStack(alignment: .top, spacing: Metrics.segmentGap) {
            ForEach(segments) { segment in
                VStack(alignment: .leading, spacing: 0) {
                    bar(segment)
                    Text(segment.name)
                        .font(Typeface.sans(
                            TypeStyle.Size.small,
                            weight: segment.role == .current ? .medium : .regular
                        ))
                        .foregroundStyle(nameColor(segment.role))
                        .lineLimit(1)
                        .minimumScaleFactor(DesignTokens.Typography.minimumScale)
                        .padding(.top, Metrics.segmentNameTop)
                    if segment.role == .current, let explanation {
                        Text(explanation)
                            .font(Typeface.sans(TypeStyle.Size.caption))
                            .foregroundStyle(Theme.inkMute)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, Metrics.explanationTop)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func bar(_ segment: StageSegment) -> some View {
        let isDark = colorScheme == .dark
        let shadow = isDark ? Metrics.trackNightShadow : Metrics.trackDayShadow
        let track = isDark
            ? Theme.paper2.opacity(Metrics.trackNightOpacity)
            : Theme.surface.opacity(Metrics.trackDayOpacity)
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(track.shadow(.inner(
                    color: shadow.color.color,
                    radius: shadow.radius,
                    x: shadow.x,
                    y: shadow.y
                )))
                Capsule()
                    .fill(segment.role == .current ? Theme.accent : Theme.ink)
                    .frame(width: proxy.size.width * min(max(segment.fill, 0), 1))
                    .accentGlow(segment.role == .current && segment.fill > 0)
            }
        }
        .frame(height: KitMetrics.Progress.thick)
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.quick), value: segment.fill)
    }

    private func nameColor(_ role: StageSegment.Role) -> Color {
        switch role {
        case .current: Theme.ink
        case .completed: Theme.inkSoft
        case .upcoming: Theme.inkMute
        }
    }
}

#Preview {
    AppearancePreviewPair {
        SegmentedStageBar(
            segments: [
                StageSegment(name: "Found", fill: 1, role: .completed),
                StageSegment(name: "Prepare", fill: 1, role: .completed),
                StageSegment(name: "Verify", fill: 1, role: .completed),
                StageSegment(name: "Patch", fill: 0.4, role: .current),
                StageSegment(name: "Finishing", fill: 0, role: .upcoming),
                StageSegment(name: "Ready", fill: 0, role: .upcoming),
            ],
            explanation: "Applying updates and DLC."
        )
        .frame(width: DesignTokens.Layout.detailMinWidth)
        .padding(DesignTokens.Spacing.xl)
    }
}
