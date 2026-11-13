import SwiftUI

/// The beat's answers (spec §3.6): they appear only when the typing is done, rising in 90ms apart (a plain fade on
/// page 1), and wrap when the column is narrow.
struct OnboardingActionsRow: View {
    /// The conversation.
    let viewModel: OnboardingChatViewModel
    /// Page 1 centres a single larger button that fades in.
    var isWelcome = false

    var body: some View {
        if isWelcome {
            HStack(spacing: ShellLayout.Onboarding.actionsGap) { buttons }
                .frame(maxWidth: .infinity, minHeight: ShellLayout.Onboarding.buttonSlot, alignment: .top)
        } else {
            FlowLayout(spacing: ShellLayout.Onboarding.actionsGap) { buttons }
                .frame(minHeight: ShellLayout.Onboarding.actionsMinHeight, alignment: .topLeading)
        }
    }

    @ViewBuilder private var buttons: some View {
        if viewModel.isReady {
            ForEach(Array(viewModel.actions.enumerated()), id: \.element.id) { index, action in
                OnboardingActionButton(
                    action: action,
                    textSize: isWelcome ? ShellLayout.Onboarding.welcomeButtonSize : TypeStyle.Size.label,
                    onHover: { viewModel.hoveredActionID = $0 ? action.id : nil },
                    choose: { Task { await viewModel.choose(action) } }
                )
                .modifier(ActionEntrance(
                    isWelcome: isWelcome,
                    delay: Double(index)
                        * ShellLayout.Onboarding.actionStagger
                ))
            }
        }
    }
}

#Preview {
    let viewModel = OnboardingChatViewModel(setup: MockOnboardingSetup(), sleep: { _ in })
    OnboardingActionsRow(viewModel: viewModel)
        .task { await viewModel.start() }
        .padding(DesignTokens.Spacing.xl)
        .background(Theme.paper)
}
