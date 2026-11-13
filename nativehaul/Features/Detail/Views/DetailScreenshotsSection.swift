import SwiftUI

/// The game's screenshots on Detail (spec §3.3 "From your last session" layout): one wide 16:9 shot across the column,
/// then up to two 4:3 shots side by side. They are the game's cached media, not the user's own captures, so the
/// heading says "Screenshots".
struct DetailScreenshotsSection: View {
    /// Image paths, in order.
    let paths: [String]
    /// The game's title (placeholders and VoiceOver).
    let title: String

    private static let smallShotCount = 2

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.Detail.sectionContentTop) {
            Eyebrow("Screenshots")
            VStack(spacing: ShellLayout.Detail.gridGap) {
                if let first = paths.first {
                    shot(first, aspect: ShellLayout.Detail.wideShotAspect, radius: ShellLayout.Detail.wideShotRadius)
                        .elevation(.regular)
                }
                let small = Array(paths.dropFirst().prefix(Self.smallShotCount))
                if !small.isEmpty {
                    HStack(spacing: ShellLayout.Detail.gridGap) {
                        ForEach(small, id: \.self) { path in
                            shot(
                                path,
                                aspect: ShellLayout.Detail.smallShotAspect,
                                radius: ShellLayout.Detail.smallShotRadius
                            )
                            .elevation(.small)
                        }
                        if small.count < Self.smallShotCount {
                            Color.clear.aspectRatio(ShellLayout.Detail.smallShotAspect, contentMode: .fit)
                        }
                    }
                }
            }
        }
    }

    private func shot(_ path: String, aspect: CGFloat, radius: CGFloat) -> some View {
        Color.clear
            .aspectRatio(aspect, contentMode: .fit)
            .overlay { ArtworkFill(path: path, title: title) }
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

#Preview {
    AppearancePreviewPair {
        DetailScreenshotsSection(paths: ["/missing/a.png", "/missing/b.png", "/missing/c.png"], title: "Lantern Coast")
            .frame(width: ShellLayout.Detail.descriptionMaxWidth)
            .padding(DesignTokens.Spacing.xl)
    }
}
