import SwiftUI

/// The couch hero's words (spec §3.7, §4.1): every slide shares one cell so nothing below moves; switching fades the
/// text out (350ms), swaps it and fades back in (450ms). Eyebrow 20pt, headline `clamp(40, 5.6vh, 80)` / 0.95, the
/// progress line `clamp(18, 2.2vh, 24)`, then the prompt cluster — A "Keep playing", L/R "Switch game" and the dots —
/// dimmed to 40% when focus is elsewhere.
struct CouchHeroText: View {
    /// Couch's state.
    let viewModel: CouchViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private typealias Metrics = CouchLayout.Hero

    var body: some View {
        let scale = viewModel.scale
        let slides = viewModel.home.slides
        let carousel = viewModel.home.carousel
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                ForEach(Array(slides.enumerated()), id: \.element.id) { offset, slide in
                    slideText(slide, scale: scale)
                        .opacity(offset == carousel.shown ? 1 : 0)
                        .accessibilityHidden(offset != carousel.shown)
                }
            }
            .opacity(carousel.isTextVisible ? 1 : 0)
            .animation(
                .easeOut(duration: carousel.isTextVisible ? HeroTiming.textIn : HeroTiming.textOut),
                value: carousel.isTextVisible
            )
            cluster(slides: slides, scale: scale)
                .padding(.top, scale(Metrics.clusterTop))
        }
        .frame(width: scale.width(Metrics.widthShare), alignment: .leading)
        .riseIn()
    }

    private func slideText(_ slide: HeroSlide, scale: CouchScale) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow(slide.copy.eyebrow, size: scale(Metrics.eyebrow))
            DisplayHeadline(
                lead: slide.copy.lead,
                emphasis: slide.copy.emphasis,
                trailing: slide.copy.trailing,
                size: scale.clamped(min: Metrics.headlineMin, share: Metrics.headlineShare, max: Metrics.headlineMax),
                lineHeight: Metrics.headlineLineHeight
            )
            .padding(.top, scale(Metrics.headlineTop))
            Text(slide.copy.progress)
                .font(Typeface.sans(scale.clamped(
                    min: Metrics.progressMin,
                    share: Metrics.progressShare,
                    max: Metrics.progressMax
                )))
                .foregroundStyle(Theme.inkSoft)
                .frame(maxWidth: scale(Metrics.progressMaxWidth), alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, scale(Metrics.progressTop))
        }
    }

    private func cluster(slides: [HeroSlide], scale: CouchScale) -> some View {
        let isFocused = viewModel.state.home.row == CouchHomeFocus.heroRow && viewModel.state.area == .content
        let family = viewModel.glyphFamily
        let playLabel = viewModel.heroGame.map(viewModel.home.playLabel(for:)) ?? "Play"
        return HStack(spacing: scale(Metrics.clusterGap)) {
            CouchPromptView(prompt: CouchPrompt(buttons: [.select], label: playLabel), family: family, scale: scale)
            if slides.count > 1 {
                CouchPromptView(
                    prompt: CouchPrompt(buttons: [.previousGame, .nextGame], label: "Switch game"),
                    family: family,
                    scale: scale
                )
                CouchHeroDots(count: slides.count, index: viewModel.home.carousel.index, scale: scale)
            }
        }
        .opacity(isFocused ? 1 : Metrics.dimmedOpacity)
        .animation(reduceMotion ? nil : Motion.settle(), value: isFocused)
    }
}

#Preview {
    CouchHeroText(viewModel: .preview)
        .padding(KitMetrics.Spacing.page)
        .frame(width: DesignTokens.Layout.windowMinWidth, height: DesignTokens.Layout.windowMinHeight)
}
