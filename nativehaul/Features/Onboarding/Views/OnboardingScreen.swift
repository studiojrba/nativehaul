import SwiftUI

/// Onboarding (spec §3.6), inside the main window in place of the shell, always at the desk: the top bar, page 1's
/// centred welcome, then the split layout — the conversation on the left in its own bottom-anchored scroll region with
/// the answers under it, the preview scene on the right. The page itself never scrolls. Pickers are the native open
/// panel (folders only for the games folder), shown by the view model's ``FilePanelPresenting``.
struct OnboardingScreen: View {
    /// The conversation.
    let viewModel: OnboardingChatViewModel

    @State private var size = CGSize(
        width: DesignTokens.Layout.windowMinWidth,
        height: DesignTokens.Layout.windowMinHeight
    )
    @State private var welcomeHeight: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Page 1 shrinks to fit a window shorter than its natural height.
    private var welcomeScale: CGFloat {
        let available = size.height - ShellLayout.Onboarding.welcomeTop - ShellLayout.Onboarding.welcomeBottom
        guard welcomeHeight > 0, available > 0 else { return 1 }
        return min(1, available / welcomeHeight)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Theme.paper
            WashBackground(slots: viewModel.beat.scene.washes)
            if viewModel.beat == .welcome {
                // Laid out at its natural size (the reservation fixes it) and scaled down to fit a short window, so
                // the top bar and "Sure, let's go" are never pushed off-screen.
                Color.clear.overlay {
                    WelcomeColumn(viewModel: viewModel, windowHeight: size.height)
                        .padding(.horizontal, ShellLayout.Onboarding.welcomeSide)
                        .fixedSize(horizontal: false, vertical: true)
                        .onGeometryChange(for: CGFloat.self, of: \.size.height) { welcomeHeight = $0 }
                        .scaleEffect(welcomeScale)
                }
                .padding(.top, ShellLayout.Onboarding.welcomeTop)
                .padding(.bottom, ShellLayout.Onboarding.welcomeBottom)
            } else {
                split
            }
            OnboardingTopBar(step: viewModel.beat.step) { viewModel.skipTour() }
        }
        .ignoresSafeArea()
        .onGeometryChange(for: CGSize.self, of: \.size) { size = $0 }
        .task {
            viewModel.revealsInstantly = viewModel.revealsInstantly || reduceMotion
            await viewModel.start()
            #if DEBUG
                if let target = viewModel.harnessTarget {
                    await ScreenshotHarness.drive(viewModel, to: target)
                }
            #endif
        }
    }

    private var split: some View {
        HStack(alignment: .top, spacing: ShellLayout.Onboarding.columnGap) {
            VStack(alignment: .leading, spacing: ShellLayout.Onboarding.actionsTop) {
                ChatScrollColumn(typist: viewModel.typist)
                OnboardingActionsRow(viewModel: viewModel)
                    .padding(.horizontal, ShellLayout.Onboarding.chatInset)
            }
            .padding(.leading, ShellLayout.Onboarding.chatLeading - ShellLayout.Onboarding.chatInset)
            .padding(.top, ShellLayout.Onboarding.chatTop)
            .padding(.bottom, ShellLayout.Onboarding.chatBottom)
            .frame(width: max(ShellLayout.Onboarding.chatMinWidth, size.width * ShellLayout.Onboarding.chatShare))
            OnboardingSceneView(viewModel: viewModel)
                .id(viewModel.beat.scene)
                .riseIn()
                .frame(maxWidth: ShellLayout.Onboarding.sceneMaxWidth)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.top, ShellLayout.Onboarding.sceneTop)
                .padding(.trailing, ShellLayout.Onboarding.sceneTrailing)
        }
    }
}

#Preview {
    var facts = OnboardingFacts()
    facts.suggestedFolder = "~/Games"
    facts.installVolume = MockVolumeInspector.preview.startup
    let viewModel = OnboardingChatViewModel(setup: MockOnboardingSetup(facts: facts))
    return OnboardingScreen(viewModel: viewModel)
        .frame(width: ShellLayout.Content.maxWidth, height: ShellLayout.Library.washHeight)
}
