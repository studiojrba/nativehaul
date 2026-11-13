import SwiftUI

/// The games scene (spec §3.6 "Shelf"): a header bar with the folder (home-abbreviated) and its status —
/// "Waiting for you…" → "Looking…" → "{n} games" once the last cover lands — over 18 slots. While the question is
/// open, hovering or focusing an answer previews its folder in the bar (note 2). Real covers from the scan rise in
/// 70ms apart, each Switch game showing what sits beside it ("Base + update + 2 DLC"); fewer real games fill fewer
/// slots, the rest stay dashed.
struct ShelfScene: View {
    /// The folder shown: the chosen one, or the hovered answer's preview.
    let folderLabel: String?
    /// Whether the folder is chosen (not just previewed).
    var isChosen = true
    /// Whether the scan is running.
    let isScanning: Bool
    /// What it found.
    let scan: OnboardingScan?

    @State private var hasFilled = false

    var body: some View {
        VStack(spacing: ShellLayout.OnboardingScenes.gridTop) {
            header
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: ShellLayout.OnboardingScenes.shelfGap),
                    count: ShellLayout.OnboardingScenes.shelfColumns
                ),
                spacing: ShellLayout.OnboardingScenes.shelfGap
            ) {
                ForEach(0 ..< OnboardingScan.shelfSlots, id: \.self) { slot in
                    tile(slot)
                }
            }
        }
        .padding(ShellLayout.OnboardingScenes.shelfPadding)
        .background {
            RoundedRectangle(cornerRadius: KitMetrics.Radius.note, style: .continuous).fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: KitMetrics.Radius.note, style: .continuous)
                .fill(Theme.surface.opacity(ShellLayout.OnboardingScenes.shelfOpacity))
        }
        .elevation(.large)
        .task(id: scan) {
            hasFilled = false
            guard let scan else { return }
            try? await Task.sleep(for: .seconds(fillDuration(for: scan)))
            hasFilled = true
        }
    }

    private var header: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "folder")
                .font(.system(size: ShellLayout.OnboardingScenes.barIcon))
                .foregroundStyle(Theme.inkSoft)
            if let folderLabel {
                Text(folderLabel)
                    .font(.system(size: TypeStyle.Size.body, design: .monospaced))
                    .foregroundStyle(Theme.inkSoft)
                    .lineLimit(DesignTokens.Lines.single)
                    .truncationMode(.middle)
            } else {
                Text("No folder chosen yet").font(Typeface.sans(TypeStyle.Size.body)).foregroundStyle(Theme.inkMute)
            }
            Spacer(minLength: 0)
            Text(status)
                .font(Typeface.sans(TypeStyle.Size.caption))
                .foregroundStyle(Theme.inkMute)
                .accessibilityAddTraits(.updatesFrequently)
        }
        .padding(.horizontal, ShellLayout.OnboardingScenes.barHorizontal)
        .padding(.vertical, ShellLayout.OnboardingScenes.barVertical)
        .background(RoundedRectangle(cornerRadius: KitMetrics.Radius.bar, style: .continuous).fill(Theme.paper2))
    }

    @ViewBuilder private func tile(_ slot: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: KitMetrics.Radius.thumb, style: .continuous)
        if let cover = scan?.covers.indices.contains(slot) == true ? scan?.covers[slot] : nil {
            Color.clear
                .aspectRatio(ShellLayout.Library.coverAspect, contentMode: .fit)
                .overlay {
                    ArtworkFill(path: cover.imagePath, title: cover.title, placeholderSize: TypeStyle.Size.small)
                }
                .overlay(alignment: .bottom) {
                    if let contents = cover.contents {
                        Text(contents.summary)
                            .font(Typeface.sans(ShellLayout.OnboardingBuild.badgeSize))
                            .foregroundStyle(Theme.lamp)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(ShellLayout.OnboardingBuild.badgePadding)
                            .background(
                                RoundedRectangle(
                                    cornerRadius: ShellLayout.OnboardingBuild.badgeRadius,
                                    style: .continuous
                                )
                                .fill(Theme.bezel.opacity(ShellLayout.OnboardingBuild.badgeOpacity))
                            )
                            .padding(ShellLayout.OnboardingBuild.badgeInset)
                    }
                }
                .clipShape(shape)
                .elevation(.small)
                .riseIn(delay: Double(slot) * ShellLayout.OnboardingScenes.coverStagger)
        } else {
            shape
                .strokeBorder(
                    Theme.ink.opacity(ShellLayout.OnboardingScenes.dashOpacity),
                    style: StrokeStyle(
                        lineWidth: ShellLayout.OnboardingScenes.dashWidth,
                        dash: ShellLayout.OnboardingScenes.dash
                    )
                )
                .aspectRatio(ShellLayout.Library.coverAspect, contentMode: .fit)
        }
    }

    private var status: String {
        guard folderLabel != nil, isChosen else { return "Waiting for you…" }
        guard let scan, !isScanning, hasFilled else { return "Looking…" }
        if scan.isUnreadable {
            return "Couldn’t open it"
        }
        return scan.gameCount == 1 ? "1 game" : "\(scan.gameCount) games"
    }

    /// The last cover's delay plus its rise: (18 − 1) × 70ms + 700ms for a full shelf.
    private func fillDuration(for scan: OnboardingScan) -> Double {
        guard !scan.covers.isEmpty else { return 0 }
        return Double(scan.covers.count - 1) * ShellLayout.OnboardingScenes.coverStagger + Motion.Duration.rise
    }
}

#Preview {
    AppearancePreviewPair {
        ShelfScene(
            folderLabel: "~/Games",
            isScanning: false,
            scan: OnboardingScan(
                gameCount: 2,
                titles: ["Lantern Coast", "Tideborn"],
                covers: [
                    ScanCover(id: UUID(), title: "Lantern Coast", imagePath: nil),
                    ScanCover(id: UUID(), title: "Tideborn", imagePath: nil),
                ]
            )
        )
        .padding(DesignTokens.Spacing.xl)
    }
}
