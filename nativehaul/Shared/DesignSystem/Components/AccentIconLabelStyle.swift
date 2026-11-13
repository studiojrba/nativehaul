import SwiftUI

/// A label with its icon in the accent colour at a set size, then the title (Make's footer rows).
struct AccentIconLabelStyle: LabelStyle {
    /// The icon size.
    let iconSize: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            configuration.icon
                .font(.system(size: iconSize))
                .foregroundStyle(Theme.accent)
            configuration.title
        }
    }
}

#Preview {
    Label("Settings keeps the door open", systemImage: "sparkles")
        .labelStyle(AccentIconLabelStyle(iconSize: ShellLayout.OnboardingBuild.footerIcon))
        .padding(DesignTokens.Spacing.lg)
}
