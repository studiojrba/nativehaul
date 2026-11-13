import SwiftUI

/// The Builds page with nothing built yet (note 17): a friendly line in nativehaul's voice and one button into the
/// build flow.
struct BuildsEmptyPanel: View {
    /// Opens Add a build.
    let addBuild: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.Builds.titleGap) {
            Eyebrow("Nothing built yet")
            DisplayHeadline(lead: "Let’s get your first game going", trailing: ".", size: TypeStyle.DisplaySize.card)
            Text(BuildsCopy.emptyLine)
                .font(Typeface.sans(TypeStyle.Size.callout))
                .foregroundStyle(Theme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Button(BuildsCopy.emptyAction, systemImage: "plus", action: addBuild)
                .buttonStyle(EmberButtonStyle())
                .padding(.top, ShellLayout.Builds.titleGap)
        }
        .frame(maxWidth: ShellLayout.Detail.descriptionMaxWidth, alignment: .leading)
    }
}

#Preview {
    AppearancePreviewPair {
        BuildsEmptyPanel {}
            .padding(DesignTokens.Spacing.xl)
    }
}
