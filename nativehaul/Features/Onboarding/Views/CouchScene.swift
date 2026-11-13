import SwiftUI

/// The final scene (spec §3.6 "Couch"): a TV showing the user's own shelf (real titles and covers from the scan, no
/// mock data), "Couch, with a controller" / "Desk, with a mouse", and — while couch is in play — the FileVault note.
/// Hovering the desktop choice dims the TV.
struct CouchScene: View {
    /// The real state.
    let facts: OnboardingFacts
    /// The hovered action.
    let hovered: OnboardingAction?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            television
                .scaleEffect(isDesk ? ShellLayout.OnboardingScenes.tvDimScale : 1)
                .opacity(isDesk ? ShellLayout.OnboardingScenes.tvDimOpacity : 1)
            HStack(spacing: ShellLayout.OnboardingScenes.modeGap) {
                modePill("Couch, with a controller", symbol: "tv", isActive: !isDesk)
                modePill("Desk, with a mouse", symbol: "desktopcomputer", isActive: isDesk)
            }
            .padding(.top, DesignTokens.Spacing.xl)
            if !isDesk {
                FileVaultNoteCard(status: facts.fileVault)
                    .padding(.top, ShellLayout.OnboardingScenes.noteTop)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: ShellLayout.OnboardingScenes.tvMaxWidth)
        .animation(reduceMotion ? nil : Motion.settle(Motion.Duration.rise), value: isDesk)
    }

    private var isDesk: Bool {
        hovered?.effect == .chooseMode(.desktop)
    }

    private var television: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Theme.paper
                WashBackground(slots: [.peach, .sky, .cream])
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    Text(facts.scan?.titles.first ?? "Your shelf")
                        .font(Typeface.display(ShellLayout.OnboardingScenes.tvTitle))
                        .foregroundStyle(Theme.ink)
                        .lineLimit(DesignTokens.Lines.single)
                    covers
                }
                .padding(ShellLayout.OnboardingScenes.screenPadding)
            }
            .aspectRatio(ShellLayout.OnboardingScenes.screenAspect, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: ShellLayout.OnboardingScenes.screenRadius, style: .continuous))
            .padding(ShellLayout.OnboardingScenes.tvBezel)
            .background(
                RoundedRectangle(cornerRadius: ShellLayout.OnboardingScenes.tvRadius, style: .continuous)
                    .fill(Theme.bezel)
            )
            .elevation(.large)
            UnevenRoundedRectangle(
                bottomLeadingRadius: KitMetrics.Radius.bar,
                bottomTrailingRadius: KitMetrics.Radius.bar
            )
            .fill(Theme.bezel.opacity(ShellLayout.OnboardingScenes.standOpacity))
            .frame(
                width: ShellLayout.OnboardingScenes.standSize.width,
                height: ShellLayout.OnboardingScenes.standSize.height
            )
        }
    }

    private var covers: some View {
        HStack(alignment: .bottom, spacing: DesignTokens.Spacing.md) {
            ForEach(
                Array((facts.scan?.covers ?? []).prefix(ShellLayout.OnboardingScenes.tvCovers).enumerated()),
                id: \.element.id
            ) { index, cover in
                let isFocused = index == 0
                let size = isFocused ? ShellLayout.OnboardingScenes.tvFocused : ShellLayout.OnboardingScenes.tvCover
                ArtworkFill(path: cover.imagePath, title: cover.title, placeholderSize: TypeStyle.Size.micro)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
                    .padding(isFocused ? ShellLayout.OnboardingScenes.tvRing : DesignTokens.Spacing.none)
                    .accentOutline(
                        isFocused,
                        in: RoundedRectangle(cornerRadius: KitMetrics.Radius.thumb, style: .continuous),
                        width: ShellLayout.OnboardingScenes.tvRing
                    )
            }
        }
    }

    private func modePill(_ title: String, symbol: String, isActive: Bool) -> some View {
        Label(title, systemImage: symbol)
            .font(Typeface.sans(TypeStyle.Size.body))
            .foregroundStyle(isActive ? Theme.ink : Theme.inkMute)
            .padding(.horizontal, ShellLayout.OnboardingScenes.modeHorizontal)
            .padding(.vertical, ShellLayout.OnboardingScenes.modeVertical)
            .background {
                if isActive {
                    Capsule().fill(Theme.surface).elevation(.small)
                }
            }
    }
}

#Preview {
    var facts = OnboardingFacts()
    facts.fileVault = .on
    return AppearancePreviewPair {
        CouchScene(facts: facts, hovered: nil).padding(DesignTokens.Spacing.xl)
    }
}
