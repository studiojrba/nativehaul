#if DEBUG
    import AppKit
    import Foundation

    /// The DEBUG-only screenshot harness (note 9): an in-memory environment over ``HarnessLibrary``, the onboarding
    /// conversation driven to the requested beat, and the window put on the requested screen at the requested size and
    /// appearance. It never reads or writes the user's library, folders, Keychain or settings.
    @MainActor
    enum ScreenshotHarness {
        /// The environment for `request`.
        static func environment(for request: ScreenshotRequest) throws -> AppEnvironment {
            let isOnboarding = if case .onboarding = request.screen {
                true
            } else {
                false
            }
            let environment = try AppEnvironment.preview(
                repository: HarnessLibrary.makeRepository(),
                runner: HarnessBuildEngineRunner(),
                hasCompletedOnboarding: !isOnboarding
            )
            if let appearance = request.appearance {
                environment.appearance.preference = appearance
            }
            return environment
        }

        /// The onboarding conversation for `beat`, over demo facts (no real folders, files or players).
        static func onboarding(
            at beat: OnboardingBeat,
            onFinish: @escaping @MainActor () -> Void
        ) -> OnboardingChatViewModel {
            var facts = OnboardingFacts()
            facts.suggestedFolder = NSHomeDirectory() + "/Switch/Games"
            facts.installLocation = NSHomeDirectory() + "/Switch/Builds"
            facts.installVolume = MockVolumeInspector.preview.startup
            facts.players = MockPlayerDetector.preview.detectedPlayers()
            let foundIDs = Set(facts.emulators.compactMap(\.profile?.id))
            facts.emulatorOffers = ComponentCatalog.bundled().components
                .filter { !foundIDs.contains($0.id) }
                .map { EmulatorOffer(entry: $0, isRecommended: false) }
            facts.fileVault = .on
            let viewModel = OnboardingChatViewModel(
                setup: MockOnboardingSetup(facts: facts, scanResult: HarnessLibrary.scan),
                sleep: { _ in },
                onFinish: onFinish
            )
            viewModel.revealsInstantly = true
            viewModel.harnessTarget = beat
            return viewModel
        }

        /// Answers until the conversation reaches `target`.
        static func drive(_ viewModel: OnboardingChatViewModel, to target: OnboardingBeat) async {
            var remaining = OnboardingBeat.allCases.count
            while viewModel.beat != target, remaining > 0, !viewModel.isFinished {
                remaining -= 1
                guard let action = answer(at: viewModel, toward: target) else { return }
                await viewModel.choose(action)
            }
            if target == .games {
                viewModel.hoveredActionID = "suggested"
            }
        }

        private static func answer(
            at viewModel: OnboardingChatViewModel,
            toward target: OnboardingBeat
        ) -> OnboardingAction? {
            var preferred = ["start", "suggested", "next", "default", "skip", "later"]
            switch (viewModel.beat, target) {
            case (.keys, .keysHelp): preferred = ["help"]
            case (.player, .playerInstall): preferred = ["install"]
            case (.final, .closing): preferred = ["couch"]
            default: break
            }
            return preferred.lazy.compactMap { id in viewModel.actions.first { $0.id == id } }.first
        }

        /// Puts the main window at `request`'s size, centred.
        static func sizeWindow(for request: ScreenshotRequest) {
            guard let size = request.windowSize,
                  let window = NSApp.windows.first(where: { $0.isVisible }) else { return }
            window.setContentSize(size)
            window.center()
        }
    }
#endif
