import SwiftUI

/// The Builds page's tools (ADR 0056): known issues and their fixes (each opens the reversible, audit-logged
/// troubleshooting flow), choosing the build engine (an override; it is found by itself, ADR 0021/0027), and checking
/// for it again.
struct BuildsToolsMenu: View {
    /// The build queue.
    let viewModel: NXNativeViewModel
    /// Opens the known issues list.
    let openKnownIssues: () -> Void
    /// Opens the engine picker.
    let chooseEngine: () -> Void

    var body: some View {
        Menu {
            Button("Known Issues and Fixes…", systemImage: "wrench.and.screwdriver", action: openKnownIssues)
            Divider()
            Button("Choose the Build Engine…", systemImage: "folder", action: chooseEngine)
            Button("Look for the Engine Again", systemImage: "arrow.clockwise") { viewModel.refreshReadiness() }
        } label: {
            Label("Tools", systemImage: "ellipsis")
                .font(Typeface.sans(TypeStyle.Size.label))
                .foregroundStyle(Theme.ink)
        }
        .menuStyle(.button)
        .buttonStyle(SurfacePillButtonStyle(isCompact: true))
        .fixedSize()
    }
}

#Preview {
    BuildsToolsMenu(viewModel: AppEnvironment.preview.makeNXNativeViewModel {}, openKnownIssues: {}, chooseEngine: {})
        .padding(DesignTokens.Spacing.xl)
}
