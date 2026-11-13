import SwiftUI

/// The player scene (spec §3.6 "Player"): a banner when the keys file is in place, then a card per real player found
/// (the user's emulator apps and the nxnative engine). Nothing found is said plainly.
struct PlayerScene: View {
    /// The real state.
    let facts: OnboardingFacts

    private static let tints: [WashSlot] = [.sky, .blush, .mint, .butter, .lilac, .peach]

    var body: some View {
        VStack(spacing: KitMetrics.Spacing.gutter) {
            if hasKeys {
                Label("Keys file in place", systemImage: "checkmark")
                    .font(Typeface.sans(TypeStyle.Size.body))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, ShellLayout.OnboardingScenes.bannerHorizontal)
                    .padding(.vertical, ShellLayout.OnboardingScenes.bannerVertical)
                    .background(Capsule().fill(Theme.wash(.mint).opacity(ShellLayout.OnboardingScenes.bannerOpacity)))
            }
            if facts.players.isEmpty {
                Text("No players found yet")
                    .font(Typeface.sans(TypeStyle.Size.label))
                    .foregroundStyle(Theme.inkMute)
                    .frame(maxWidth: .infinity)
                    .padding(KitMetrics.Spacing.section)
                    .overlay {
                        RoundedRectangle(cornerRadius: KitMetrics.Radius.panel, style: .continuous)
                            .strokeBorder(
                                Theme.ink.opacity(ShellLayout.OnboardingScenes.keysDashOpacity),
                                style: StrokeStyle(
                                    lineWidth: ShellLayout.OnboardingScenes.dashWidth,
                                    dash: ShellLayout.OnboardingScenes.dash
                                )
                            )
                    }
            }
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: KitMetrics.Spacing.gutter), GridItem(.flexible())],
                spacing: KitMetrics.Spacing.gutter
            ) {
                ForEach(Array(shown.enumerated()), id: \.element.id) { index, player in
                    PlayerCard(player: player, tint: Self.tints[index % Self.tints.count])
                        .riseIn(delay: Double(index) * ShellLayout.Onboarding.actionStagger)
                }
            }
        }
        .frame(maxWidth: ShellLayout.OnboardingScenes.playerMaxWidth)
    }

    private var shown: [DetectedPlayer] {
        Array(facts.players.prefix(ShellLayout.OnboardingScenes.maximumPlayers))
    }

    private var hasKeys: Bool {
        facts.detectedKeys != nil || facts.keysOutcome == .placed || facts.keysOutcome == .alreadyThere
    }
}

#Preview {
    var facts = OnboardingFacts()
    facts.players = MockPlayerDetector.preview.detectedPlayers()
    facts.keysOutcome = .placed
    return AppearancePreviewPair {
        PlayerScene(facts: facts).padding(DesignTokens.Spacing.xl)
    }
}
