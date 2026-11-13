import SwiftUI

/// Builds' segmented progress at couch size (spec §3.4 at 10-foot scale): one pill per stage; completed in `ink`, the
/// current one filling in the accent (glowing at night), upcoming on a sunken track; each stage's name underneath.
struct CouchStageBar: View {
    /// The segments, in order.
    let segments: [StageSegment]
    /// The couch scale.
    let scale: CouchScale

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = CouchLayout.Builds

    var body: some View {
        HStack(alignment: .top, spacing: scale(Metrics.segmentGap)) {
            ForEach(segments) { segment in
                VStack(alignment: .leading, spacing: scale(Metrics.segmentGap)) {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.paper2)
                            Capsule()
                                .fill(segment.role == .current ? Theme.accent : Theme.ink)
                                .frame(width: proxy.size.width * segment.fill)
                                .accentGlow(segment.role == .current)
                        }
                    }
                    .frame(height: scale(Metrics.segmentHeight))
                    Text(segment.name)
                        .font(Typeface.sans(
                            scale(Metrics.stageName),
                            weight: segment.role == .current ? .medium : .regular
                        ))
                        .foregroundStyle(segment.role == .upcoming ? Theme.inkMute : Theme.ink)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.quick), value: segments)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let scale = CouchScale(size: CGSize(width: DesignTokens.Layout.windowMinWidth, height: CouchLayout.referenceHeight))
    AppearancePreviewPair {
        CouchStageBar(
            segments: [
                StageSegment(name: "Found", fill: 1, role: .completed),
                StageSegment(name: "Prepare", fill: 1, role: .completed),
                StageSegment(name: "Verify", fill: 0.4, role: .current),
                StageSegment(name: "Patch", fill: 0, role: .upcoming),
            ],
            scale: scale
        )
        .padding(DesignTokens.Spacing.xl)
    }
}
