import SwiftUI

/// "Back on your shelf" (Make `BuildTutorial` launch): the finished build next to a few of the user's own games, the
/// ember Play under the first, and the honest line about where nxnative comes from (ADR 0027).
struct BuildLaunchCard: View {
    /// The user's games from the scan (titles and covers), or placeholders when none were found.
    let covers: [ScanCover]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow("Back on your shelf")
            HStack(alignment: .bottom, spacing: ShellLayout.OnboardingBuild.launchGap) {
                ForEach(Array(shown.enumerated()), id: \.offset) { index, cover in
                    tile(cover, isFirst: index == 0)
                }
            }
            .padding(.top, ShellLayout.OnboardingBuild.contentTop)
            Label("Your own copy of nxnative · never bundled", systemImage: "shippingbox")
                .font(Typeface.sans(TypeStyle.Size.small))
                .foregroundStyle(Theme.inkSoft)
                .labelStyle(AccentIconLabelStyle(iconSize: ShellLayout.OnboardingBuild.footerIcon))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.footerRadius, style: .continuous)
                        .fill(Theme.paper2)
                )
                .padding(.top, ShellLayout.OnboardingBuild.footerTop)
        }
        .tutorialPanel()
        .frame(maxWidth: ShellLayout.OnboardingBuild.panelMaxWidth)
    }

    private var shown: [ScanCover?] {
        let real = covers.prefix(ShellLayout.OnboardingBuild.launchCovers).map { Optional($0) }
        return real.isEmpty ? Array(repeating: nil, count: ShellLayout.OnboardingBuild.launchCovers) : real
    }

    private func tile(_ cover: ScanCover?, isFirst: Bool) -> some View {
        Color.clear
            .aspectRatio(ShellLayout.Library.coverAspect, contentMode: .fit)
            .overlay {
                ArtworkFill(
                    path: cover?.imagePath,
                    title: cover?.title ?? "Your game",
                    placeholderSize: TypeStyle.Size.body,
                    showsTitle: cover != nil
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.launchRadius, style: .continuous))
            .elevation(.regular)
            .frame(width: isFirst ? ShellLayout.OnboardingBuild.launchFirst : ShellLayout.OnboardingBuild.launchOther)
            .opacity(isFirst ? 1 : ShellLayout.OnboardingBuild.launchOtherOpacity)
            .overlay(alignment: .bottom) {
                if isFirst {
                    Label("Play", systemImage: "play.fill")
                        .font(Typeface.sans(TypeStyle.Size.caption, weight: .medium))
                        .foregroundStyle(Theme.onAccent)
                        .padding(.horizontal, ShellLayout.OnboardingBuild.playHorizontal)
                        .padding(.vertical, ShellLayout.OnboardingBuild.playVertical)
                        .background { EmberFill(shape: Capsule()) }
                        .fixedSize()
                        .offset(y: ShellLayout.OnboardingBuild.playDrop)
                }
            }
    }
}

#Preview {
    AppearancePreviewPair {
        BuildLaunchCard(covers: [
            ScanCover(id: UUID(), title: "Lantern Coast", imagePath: nil),
            ScanCover(id: UUID(), title: "Tideborn", imagePath: nil),
        ])
        .padding(DesignTokens.Spacing.xl)
    }
}
