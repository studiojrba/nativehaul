import SwiftUI

/// "Files found together" (note 10): one game's cover and what sits beside it in its folder — the base game, an update,
/// its DLC — sorted automatically. It shows a real game from the scan when one has extras; otherwise it is labelled
/// as an example.
struct BuildFolderCard: View {
    /// The game shown.
    let title: String
    /// Its cover, if any.
    let imagePath: String?
    /// What sits together in its folder.
    let contents: ScanContents
    /// Whether this is an illustration rather than the user's own game.
    let isExample: Bool

    var body: some View {
        HStack(spacing: ShellLayout.OnboardingBuild.folderGap) {
            Color.clear
                .aspectRatio(ShellLayout.Library.coverAspect, contentMode: .fit)
                .overlay { ArtworkFill(path: imagePath, title: title, placeholderSize: TypeStyle.Size.large) }
                .frame(width: ShellLayout.OnboardingBuild.folderCover)
                .clipShape(RoundedRectangle(
                    cornerRadius: ShellLayout.OnboardingBuild.folderCoverRadius,
                    style: .continuous
                ))
                .elevation(.large)
            VStack(alignment: .leading, spacing: 0) {
                Eyebrow(isExample ? "For example · files found together" : "Files found together")
                Text(title)
                    .font(Typeface.display(ShellLayout.OnboardingBuild.folderTitle))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(DesignTokens.Lines.title)
                    .padding(.top, ShellLayout.OnboardingBuild.folderTitleTop)
                parts.padding(.top, ShellLayout.OnboardingBuild.partsTop)
                Label("Ready to build", systemImage: "checkmark")
                    .font(Typeface.sans(TypeStyle.Size.caption))
                    .foregroundStyle(Theme.ink)
                    .padding(.horizontal, ShellLayout.OnboardingBuild.pillHorizontal)
                    .padding(.vertical, ShellLayout.OnboardingBuild.pillVertical)
                    .background(Capsule().fill(Theme.cream))
                    .padding(.top, ShellLayout.OnboardingBuild.pillTop)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .tutorialPanel()
        .frame(maxWidth: ShellLayout.OnboardingBuild.folderMaxWidth)
    }

    private var parts: some View {
        VStack(spacing: ShellLayout.OnboardingBuild.partsGap) {
            HairlineDivider()
            ForEach(partNames, id: \.self) { name in
                HStack {
                    Text(name)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: ShellLayout.OnboardingBuild.partCheck))
                        .foregroundStyle(Theme.success)
                }
                .font(Typeface.sans(TypeStyle.Size.small))
                .foregroundStyle(Theme.ink)
            }
            .padding(.top, DesignTokens.Spacing.none)
        }
    }

    private var partNames: [String] {
        var names = ["Base game"]
        if contents.hasUpdate {
            names.append("Update")
        }
        if contents.dlcCount > 0 {
            names.append(contents.dlcCount == 1 ? "1 DLC pack" : "\(contents.dlcCount) DLC packs")
        }
        return names
    }
}

#Preview {
    AppearancePreviewPair {
        BuildFolderCard(
            title: "Lantern Coast",
            imagePath: nil,
            contents: ScanContents(hasUpdate: true, dlcCount: 2),
            isExample: true
        )
        .padding(DesignTokens.Spacing.xl)
    }
}
