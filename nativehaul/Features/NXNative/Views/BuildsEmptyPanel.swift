import SwiftUI

/// The Builds page with nothing in the oven: a calm line about what shows here and one way to start.
struct BuildsEmptyPanel: View {
    /// Opens Add a build.
    let addBuild: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.Builds.titleGap) {
            Eyebrow("Nothing in the oven")
            DisplayHeadline(lead: "Quiet in the kitchen", trailing: ".", size: TypeStyle.DisplaySize.card)
            Text("When you add a Switch game to build, its progress shows here, stage by stage.")
                .font(Typeface.sans(TypeStyle.Size.callout))
                .foregroundStyle(Theme.inkSoft)
                .fixedSize(horizontal: false, vertical: true)
            Button("Add a build", systemImage: "plus", action: addBuild)
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
