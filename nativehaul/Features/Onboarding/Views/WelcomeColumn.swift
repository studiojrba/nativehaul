import SwiftUI

/// Page 1 (spec §3.6): one centred column up to 560pt — the logo cluster, then the intro as centred bubbles at 16pt
/// (note 1),
/// then "Sure, let's go". A hidden copy of the finished conversation (plus the button's slot) reserves the final height
/// from the first frame, so the logo never moves as bubbles arrive.
struct WelcomeColumn: View {
    /// The conversation.
    let viewModel: OnboardingChatViewModel
    /// The window height (sizes the cluster).
    let windowHeight: CGFloat

    @State private var width: CGFloat = ShellLayout.Onboarding.welcomeMaxWidth

    var body: some View {
        VStack(spacing: 0) {
            WelcomeLogoCluster(height: clusterHeight).riseIn()
            ZStack(alignment: .top) {
                reservation
                VStack(spacing: ShellLayout.Onboarding.bubbleGap) {
                    ForEach(viewModel.typist.messages) { message in
                        ChatBubble(
                            message: message,
                            progress: viewModel.typist.progress(of: message),
                            style: .welcome,
                            maxWidth: bubbleWidth
                        )
                    }
                    OnboardingActionsRow(viewModel: viewModel, isWelcome: true)
                        .padding(.top, ShellLayout.Onboarding.buttonTop)
                }
            }
            .padding(.top, ShellLayout.Onboarding.conversationTop)
        }
        .frame(maxWidth: ShellLayout.Onboarding.welcomeMaxWidth)
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { width = $0 }
    }

    /// The finished conversation, invisible, holding its space.
    private var reservation: some View {
        VStack(spacing: ShellLayout.Onboarding.bubbleGap) {
            ForEach(Array(OnboardingScript.welcome.enumerated()), id: \.offset) { index, text in
                ChatBubble(
                    message: ChatMessage(id: -index - 1, sender: .app, text: text),
                    progress: .sent,
                    style: .welcome,
                    maxWidth: bubbleWidth,
                    isStill: true
                )
            }
            Color.clear
                .frame(height: ShellLayout.Onboarding.buttonSlot)
                .padding(.top, ShellLayout.Onboarding.buttonTop)
        }
        .hidden()
        .accessibilityHidden(true)
    }

    private var bubbleWidth: CGFloat {
        width * ShellLayout.Onboarding.bubbleMaxShare
    }

    private var clusterHeight: CGFloat {
        TypeStyle.clampedDisplay(
            width: windowHeight,
            min: ShellLayout.Onboarding.clusterMin,
            share: ShellLayout.Onboarding.clusterShare,
            max: ShellLayout.Onboarding.clusterMax
        )
    }
}

#Preview {
    let viewModel = OnboardingChatViewModel(setup: MockOnboardingSetup(), sleep: { _ in })
    WelcomeColumn(viewModel: viewModel, windowHeight: DesignTokens.Layout.windowMinHeight)
        .task { await viewModel.start() }
        .padding(DesignTokens.Spacing.xl)
        .background(Theme.paper)
}
