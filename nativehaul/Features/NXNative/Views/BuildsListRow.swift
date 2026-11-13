import SwiftUI

/// One build in the Builds list (spec §3.4): the cover thumb, the short title, "Ready" / "Queued" / "{stage} · {pct}%",
/// and while it is under way a 4pt bar. The selected row sits on `surface` with `elev`; hovering shows `surface` 50%.
struct BuildsListRow: View {
    /// The build.
    let job: BuildJob
    /// Its short title.
    let title: String
    /// Its cover art.
    let coverPath: String?
    /// Whether it is selected.
    let isSelected: Bool
    /// Selects it.
    let select: () -> Void

    @State private var isHovered = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = ShellLayout.Builds

    var body: some View {
        Button(action: select) {
            HStack(spacing: Metrics.rowGapInside) {
                ArtworkFill(path: coverPath, title: title, placeholderSize: TypeStyle.Size.micro)
                    .frame(width: Metrics.thumb.width, height: Metrics.thumb.height)
                    .clipShape(RoundedRectangle(cornerRadius: KitMetrics.Radius.thumb, style: .continuous))
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(Typeface.sans(TypeStyle.Size.label, weight: .medium))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(1)
                    Text(BuildsCopy.rowStatus(for: job))
                        .font(Typeface.sans(TypeStyle.Size.caption))
                        .foregroundStyle(job.pipeline.isFailed ? Theme.danger : Theme.inkMute)
                        .lineLimit(1)
                        .padding(.top, Metrics.rowStatusTop)
                    if job.pipeline.isActive, job.status != .queued {
                        PillProgressBar(
                            value: job.pipeline.overallFraction,
                            height: KitMetrics.Progress.thin,
                            fill: Theme.ink.opacity(KitMetrics.Progress.quietFillOpacity),
                            glows: false
                        )
                        .padding(.top, Metrics.rowBarTop)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(Metrics.rowPadding)
            .padding(.trailing, Metrics.rowTrailing - Metrics.rowPadding)
            .background(background)
            .contentShape(RoundedRectangle(cornerRadius: Metrics.rowRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .pointerStyle(.link)
        .onHover { isHovered = $0 }
        .animation(reduceMotion ? nil : Motion.settle(), value: isSelected)
        .animation(reduceMotion ? nil : Motion.settle(), value: isHovered)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder private var background: some View {
        let shape = RoundedRectangle(cornerRadius: Metrics.rowRadius, style: .continuous)
        if isSelected {
            shape.fill(Theme.surface).elevation(.regular)
        } else if isHovered {
            shape.fill(Theme.surface.opacity(Metrics.rowHoverOpacity))
        }
    }
}

#Preview {
    AppearancePreviewPair {
        BuildsListRow(
            job: BuildJob(
                sourcePath: "/s/a.nsp",
                title: TitleInfo(titleID: "0100000000010000", name: "Lantern Coast", architecture: .bit64)
            ),
            title: "Lantern Coast",
            coverPath: nil,
            isSelected: true
        ) {}
            .frame(width: ShellLayout.Builds.listMinWidth)
            .padding(DesignTokens.Spacing.xl)
    }
}
