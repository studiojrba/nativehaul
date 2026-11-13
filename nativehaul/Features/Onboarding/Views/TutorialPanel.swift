import SwiftUI

/// The build tutorial's frosted panel (Make `rounded-[36px] bg-surface/55 shadow-warm-lg backdrop-blur-xl`).
struct TutorialPanel: ViewModifier {
    /// Inner padding.
    var padding: CGFloat = ShellLayout.OnboardingBuild.panelPadding
    /// Corner radius.
    var radius: CGFloat = ShellLayout.OnboardingBuild.panelRadius

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return content
            .padding(padding)
            .background {
                shape.fill(.ultraThinMaterial)
                shape.fill(Theme.surface.opacity(ShellLayout.OnboardingBuild.panelOpacity))
            }
            .elevation(.large)
    }
}

extension View {
    /// Sets the view on the build tutorial's frosted panel.
    func tutorialPanel(
        padding: CGFloat = ShellLayout.OnboardingBuild.panelPadding,
        radius: CGFloat = ShellLayout.OnboardingBuild.panelRadius
    ) -> some View {
        modifier(TutorialPanel(padding: padding, radius: radius))
    }
}

#Preview {
    Text("Panel").tutorialPanel().padding(DesignTokens.Spacing.xl).background(Theme.paper)
}
