import SwiftUI

/// The Home hero (ADR 0035): installed games with banner art, one at a time, with the title, one quiet state line and
/// a big Play button. Rotates about every 6 s with a crossfade, pauses while hovered, and has arrows and dots.
/// Under Reduce Motion it never auto-advances and changes without a fade. Renders nothing with no heroes.
struct HomeHero: View {
    /// Games to feature, in order.
    let heroes: [Game]
    /// Rotation state.
    let carousel: HeroCarousel
    /// Makes the Play button's view model.
    let makeLaunch: (Game) -> GameLaunchViewModel
    /// Reference time for the state line.
    var now: Date = .now
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.designIntensity) private var intensity

    var body: some View {
        if let game = current {
            ZStack(alignment: .bottomLeading) {
                HeroBanner(imagePath: game.heroImagePath)
                    .id(game.id)
                    .transition(.opacity)
                details(for: game)
            }
            .frame(maxWidth: .infinity)
            .frame(height: EnergyLevel.of(intensity).heroHeight)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.lg))
            .overlay(alignment: .bottomTrailing) {
                if heroes.count > 1 {
                    controls
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: DesignTokens.Home.crossfadeSeconds), value: game.id)
            .onHover { carousel.isHovered = $0 }
            .task(id: heroes.map(\.id)) { await rotate() }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Featured: \(game.title)")
        }
    }

    private var current: Game? {
        heroes.isEmpty ? nil : heroes[min(carousel.index, heroes.count - 1)]
    }

    private func details(for game: Game) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            NavigationLink(value: game.id) {
                Text(game.title)
                    .font(EnergyLevel.of(intensity).heroTitle)
                    .tracking(DesignTokens.Home.heroTitleTracking)
                    .lineLimit(DesignTokens.Lines.title)
                    .minimumScaleFactor(DesignTokens.Typography.minimumScale)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.plain)
            Text(JumpBackIn.line(for: game, now: now))
                .font(DesignTokens.Typography.monospaced)
                .lineLimit(DesignTokens.Lines.single)
            HeroPlayButton(game: game, makeLaunch: makeLaunch)
                .id(game.id)
        }
        .foregroundStyle(Theme.onArtwork)
        .padding(DesignTokens.Spacing.xxl)
    }

    private var controls: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Button("Previous game", systemImage: "chevron.left") { carousel.step(by: -1) }
            ForEach(heroes.indices, id: \.self) { index in
                Button { carousel.select(index) } label: { HeroDot(isCurrent: index == carousel.index) }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Show \(heroes[index].title)")
                    .accessibilityAddTraits(index == carousel.index ? .isSelected : [])
            }
            Button("Next game", systemImage: "chevron.right") { carousel.step(by: 1) }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .foregroundStyle(Theme.onArtwork)
        .padding(DesignTokens.Spacing.sm)
        .smokedGlass(in: Capsule())
        .padding(DesignTokens.Spacing.lg)
    }

    private func rotate() async {
        carousel.update(count: heroes.count)
        guard !reduceMotion else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: HeroCarousel.interval)
            guard !Task.isCancelled else { return }
            carousel.tick()
        }
    }
}

#Preview {
    NavigationStack {
        HomeHero(heroes: [], carousel: HeroCarousel()) { AppEnvironment.preview.makeGameLaunchViewModel(for: $0) }
    }
}
