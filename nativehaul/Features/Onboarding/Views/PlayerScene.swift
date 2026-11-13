import SwiftUI

/// The emulator scene (notes 5, 12): a banner for what is already here, a card per emulator found (real name, icon,
/// version, where it is) and per emulator on offer from its official source (version and source shown, ticked or not),
/// and — once the user says go — each install's real progress, signature verdict and Install button.
struct PlayerScene: View {
    /// The conversation.
    let viewModel: OnboardingChatViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: ShellLayout.OnboardingBuild.contentTop) {
            Label(banner, systemImage: facts.emulators.isEmpty ? "circle" : "checkmark.circle")
                .font(Typeface.sans(TypeStyle.Size.small))
                .foregroundStyle(Theme.ink)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, ShellLayout.OnboardingBuild.bannerHorizontal)
                .padding(.vertical, ShellLayout.OnboardingBuild.bannerVertical)
                .background(Capsule().fill(Theme.wash(.mint).opacity(ShellLayout.OnboardingBuild.bannerOpacity)))
            if viewModel.installs.isEmpty {
                cards
            } else {
                installs
            }
        }
        .tutorialPanel(padding: ShellLayout.OnboardingBuild.panelPaddingCompact)
        .frame(maxWidth: ShellLayout.OnboardingBuild.folderMaxWidth)
    }

    private var facts: OnboardingFacts {
        viewModel.facts
    }

    private var banner: String {
        let found = facts.emulators
        guard !found.isEmpty else { return "No emulator apps found yet" }
        return found.count == 1 ? "\(found[0].name) is installed" : "\(found.count) emulators installed"
    }

    private var cards: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: ShellLayout.OnboardingBuild.stepGap),
                GridItem(.flexible()),
            ],
            spacing: ShellLayout.OnboardingBuild.stepGap
        ) {
            ForEach(Array(entries.enumerated()), id: \.offset) { index, content in
                card(content).riseIn(delay: Double(index) * ShellLayout.Onboarding.actionStagger)
            }
        }
    }

    private var entries: [EmulatorCard.Content] {
        let found = facts.emulators.map(EmulatorCard.Content.found)
        let offers = facts.emulatorOffers.map {
            EmulatorCard.Content.offer($0, isTicked: viewModel.selectedOfferIDs.contains($0.id))
        }
        return Array((found + offers).prefix(ShellLayout.OnboardingBuild.maximumCards))
    }

    private func card(_ content: EmulatorCard.Content) -> some View {
        EmulatorCard(content: content) {
            if case let .offer(offer, _) = content {
                viewModel.toggleOffer(offer.id)
            }
        }
    }

    private var installs: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            ForEach(viewModel.installs, id: \.entry.id) { install in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(install.entry.name)
                        .font(Typeface.sans(TypeStyle.Size.small, weight: .medium))
                        .foregroundStyle(Theme.ink)
                    ComponentInstallControl(viewModel: install)
                    Text(sourceLine(for: install.entry))
                        .font(Typeface.sans(TypeStyle.Size.micro))
                        .foregroundStyle(Theme.inkMute)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, ShellLayout.OnboardingBuild.closingCardHorizontal)
                .padding(.vertical, ShellLayout.OnboardingBuild.closingCardVertical)
                .background(
                    RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.closingCardRadius, style: .continuous)
                        .fill(Theme.paper2)
                )
            }
        }
    }

    private func sourceLine(for entry: ComponentEntry) -> String {
        let offer = EmulatorOffer(entry: entry, isRecommended: false)
        return "\(offer.versionLabel) · \(offer.sourceLabel)"
    }
}

#Preview {
    var facts = OnboardingFacts()
    facts.emulatorOffers = ComponentCatalog.bundled().components.map {
        EmulatorOffer(entry: $0, isRecommended: EmulatorOffer.recommendedIDs.contains($0.id))
    }
    let viewModel = OnboardingChatViewModel(setup: MockOnboardingSetup(facts: facts), sleep: { _ in })
    return AppearancePreviewPair {
        PlayerScene(viewModel: viewModel)
            .task { await viewModel.start() }
            .padding(DesignTokens.Spacing.xl)
    }
}
