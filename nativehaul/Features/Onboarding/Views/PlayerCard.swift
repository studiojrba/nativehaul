import SwiftUI

/// One real player in the player scene (spec §3.6 "Player"): its initial on a wash chip, its name, its version and
/// where it is, and a quiet status pill.
struct PlayerCard: View {
    /// The player.
    let player: DetectedPlayer
    /// The chip's wash.
    let tint: WashSlot

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(String(player.name.prefix(1)).uppercased())
                .font(Typeface.display(ShellLayout.OnboardingScenes.playerInitial))
                .foregroundStyle(Theme.ink)
                .frame(width: ShellLayout.OnboardingScenes.playerChip, height: ShellLayout.OnboardingScenes.playerChip)
                .background(
                    RoundedRectangle(cornerRadius: ShellLayout.OnboardingScenes.playerChipRadius, style: .continuous)
                        .fill(Theme.wash(tint))
                )
            Text(player.name)
                .font(Typeface.sans(ShellLayout.OnboardingScenes.playerName, weight: .medium))
                .foregroundStyle(Theme.ink)
                .padding(.top, KitMetrics.Spacing.gutter)
            Text(player.detail)
                .font(Typeface.sans(TypeStyle.Size.small))
                .foregroundStyle(Theme.inkMute)
                .lineLimit(DesignTokens.Lines.single)
                .truncationMode(.middle)
            Text(player.kind == .buildEngine ? "Builds Switch games" : "Installed")
                .font(Typeface.sans(TypeStyle.Size.caption))
                .foregroundStyle(Theme.inkSoft)
                .padding(.horizontal, ShellLayout.OnboardingScenes.statusHorizontal)
                .padding(.vertical, ShellLayout.OnboardingScenes.statusVertical)
                .background(Capsule().fill(Theme.paper2))
                .padding(.top, KitMetrics.Spacing.gutter)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.xl)
        .background(RoundedRectangle(cornerRadius: KitMetrics.Radius.panel, style: .continuous).fill(Theme.surface))
        .elevation(.regular)
    }
}

#Preview {
    AppearancePreviewPair {
        if let player = MockPlayerDetector.preview.engine {
            PlayerCard(player: player, tint: .mint).padding(DesignTokens.Spacing.xl)
        }
    }
}
