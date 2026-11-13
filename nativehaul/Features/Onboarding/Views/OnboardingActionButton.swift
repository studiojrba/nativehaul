import SwiftUI

/// One answer pill (spec §3.6): the primary in ember, the rest frosted; hovering tells the scene to preview its effect.
struct OnboardingActionButton: View {
    /// The action.
    let action: OnboardingAction
    /// Text size (page 1's "Sure, let's go" is larger).
    var textSize = TypeStyle.Size.label
    /// Hover in or out.
    let onHover: (Bool) -> Void
    /// Chosen.
    let choose: () -> Void

    var body: some View {
        Group {
            if action.isPrimary {
                Button(action: choose) { label }.buttonStyle(EmberButtonStyle(isCompact: true))
            } else {
                Button(action: choose) { label }.buttonStyle(SurfacePillButtonStyle(isCompact: true))
            }
        }
        .onHover(perform: onHover)
    }

    private var label: some View {
        Text(action.label).font(Typeface.sans(textSize, weight: action.isPrimary ? .medium : .regular))
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: ShellLayout.Onboarding.actionsGap) {
            OnboardingActionButton(
                action: OnboardingAction(
                    id: "a",
                    label: "Couch mode, please",
                    isPrimary: true,
                    effect: .chooseMode(.couch)
                ),
                onHover: { _ in },
                choose: {}
            )
            OnboardingActionButton(
                action: OnboardingAction(id: "b", label: "I’ll stick with desktop", effect: .chooseMode(.desktop)),
                onHover: { _ in },
                choose: {}
            )
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
