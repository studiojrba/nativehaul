import SwiftUI

/// One horizontal bar, 0–100%, split into a segment per build stage (J.R's direction, ADR 0028). Finished segments
/// are full strength, the current one fills with its stage fraction, upcoming ones stay on the track colour. Without
/// stage markers it is indeterminate rather than a stuck 0%. Reduce Motion: values land without animation.
struct BuildProgressBar: View {
    /// Parsed stage state.
    let progress: BuildProgress
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            if progress.hasStages {
                header
                segments
            } else {
                Text("Building…").font(DesignTokens.Typography.headline)
                ProgressView().progressViewStyle(.linear).tint(Theme.primaryText)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(accessibilityText))
    }

    private var header: some View {
        FlowLayout(spacing: DesignTokens.Spacing.md) {
            Text(stageTitle).font(DesignTokens.Typography.headline)
            Text("\(progress.displayedPercent)%")
                .font(DesignTokens.Typography.monospaced)
                .foregroundStyle(Theme.primaryText)
            if let times {
                Text(times).font(DesignTokens.Typography.monospacedSmall).foregroundStyle(Theme.secondaryText)
            }
        }
    }

    private var segments: some View {
        HStack(spacing: DesignTokens.Builds.segmentGap) {
            ForEach(Array(progress.segments.enumerated()), id: \.offset) { _, fill in
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.surfaceRaised)
                        Capsule().fill(Theme.primaryText).frame(width: proxy.size.width * fill)
                    }
                }
            }
        }
        .frame(height: DesignTokens.Builds.progressHeight)
        .animation(reduceMotion ? nil : .easeOut(duration: DesignTokens.Motion.standard), value: progress.segments)
    }

    private var stageTitle: String {
        let stage = max(progress.currentStage, progress.completedStages)
        let name = progress.stageName.isEmpty ? "Stage" : progress.stageName
        return "\(name) · \(stage) of \(progress.totalStages)"
    }

    private var times: String? {
        guard let elapsed = progress.elapsed else { return nil }
        return progress.eta.map { "\(elapsed) · ETA \($0)" } ?? elapsed
    }

    private var accessibilityText: String {
        progress.hasStages ? "\(stageTitle), \(progress.displayedPercent) percent" : "Building"
    }
}

#Preview {
    var progress = BuildProgress()
    progress.consume("✓ [1/6] extract (1:39)")
    progress.consume("[2/6] rewrite · patch_nso: 91%, 22.2/~24.4 GB, 1:00 · ETA 0:06")
    return VStack(spacing: DesignTokens.Spacing.xl) {
        BuildProgressBar(progress: progress)
        BuildProgressBar(progress: BuildProgress())
    }
    .padding(DesignTokens.Spacing.xl)
    .background(Theme.canvas)
}
