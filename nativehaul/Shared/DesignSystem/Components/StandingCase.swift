import SwiftUI

/// A game case standing in the hero (spec §4.1 `HeroCase`): the game's real cover in a case-proportioned frame, tilted
/// as a 3D object (rest rotateY −18° / rotateX 5°), turning toward the viewer on hover or couch focus (−6° / 2°,
/// ×1.05, 1000ms ease-settle), bobbing on the `float` idle and casting a warm floor shadow. Reusable for couch; the
/// full
/// six-face case lives on Detail.
struct StandingCase: View {
    /// Cover art path.
    let coverPath: String?
    /// The game's title (placeholder and accessibility).
    let title: String
    /// The game's palette (the case edge).
    var palette: GamePalette = .neutral
    /// Turned toward the viewer (hover on desktop, focus on couch).
    var isTurned = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = width / ShellLayout.StandingCase.aspectRatio
            // SwiftUI's perspective is relative to the view's size: height / 1400 matches CSS `perspective: 1400px`.
            ZStack(alignment: .bottom) {
                floorShadow(width: width)
                caseBody(width: width)
                    .frame(width: width, height: height)
                    .rotation3DEffect(
                        .degrees(isTurned ? HeroTiming.hoverYaw : HeroTiming.restYaw),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: height / HeroTiming.perspective
                    )
                    .rotation3DEffect(
                        .degrees(isTurned ? HeroTiming.hoverPitch : HeroTiming.restPitch),
                        axis: (x: 1, y: 0, z: 0),
                        perspective: height / HeroTiming.perspective
                    )
                    .scaleEffect(isTurned ? HeroTiming.hoverScale : 1)
                    .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.slow), value: isTurned)
            }
            .frame(width: width, height: height, alignment: .bottom)
        }
        .aspectRatio(ShellLayout.StandingCase.aspectRatio, contentMode: .fit)
        .floatIdle()
        .accessibilityElement()
        .accessibilityLabel(Text(title))
    }

    private func caseBody(width: CGFloat) -> some View {
        let outer = RoundedRectangle(cornerRadius: ShellLayout.StandingCase.radius, style: .continuous)
        let inset = width * ShellLayout.StandingCase.coverInsetShare
        return ZStack(alignment: .leading) {
            outer.fill(palette.deep.color)
            ArtworkFill(path: coverPath, title: title)
                .clipShape(RoundedRectangle(cornerRadius: ShellLayout.StandingCase.coverRadius, style: .continuous))
                .padding(inset)
            LinearGradient(
                colors: [palette.deep.color.opacity(DesignTokens.Opacity.disabled), .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: width * ShellLayout.StandingCase.edgeWidthShare)
        }
        .clipShape(outer)
        .elevation(.large)
    }

    private func floorShadow(width: CGFloat) -> some View {
        Ellipse()
            .fill(Theme.floor)
            .frame(width: width * HeroTiming.floorWidthShare, height: ShellLayout.StandingCase.floorHeight)
            .blur(radius: ShellLayout.StandingCase.floorBlur)
            .offset(y: ShellLayout.StandingCase.floorHeight)
    }
}

#Preview {
    AppearancePreviewPair {
        StandingCase(coverPath: nil, title: "Lantern Coast")
            .frame(width: ShellLayout.Hero.caseMaxWidth / 2)
            .padding(KitMetrics.Spacing.page)
    }
}
