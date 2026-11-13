import SwiftUI

/// One emulator in the player scene (notes 5, 12; Make `PlayerCard` values): its real icon (or initial, before it is
/// installed), its real name, version and source, and either its installed check or a tick box.
struct EmulatorCard: View {
    /// What the card shows.
    enum Content {
        /// Found on this Mac.
        case found(DetectedPlayer)
        /// On offer from its official source; `isTicked` is the user's choice.
        case offer(EmulatorOffer, isTicked: Bool)
    }

    /// The emulator.
    let content: Content
    /// Ticks or unticks an offer.
    var toggle: () -> Void = {}

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.cardRadius, style: .continuous)
        Button(action: toggle) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    icon
                    Spacer(minLength: DesignTokens.Spacing.lg)
                    marker
                }
                Text(name)
                    .font(Typeface.sans(ShellLayout.OnboardingBuild.name, weight: .medium))
                    .foregroundStyle(Theme.ink)
                    .padding(.top, ShellLayout.OnboardingBuild.nameTop)
                Text(detail)
                    .font(Typeface.sans(TypeStyle.Size.caption))
                    .foregroundStyle(Theme.inkMute)
                    .lineLimit(DesignTokens.Lines.single)
                    .truncationMode(.middle)
                    .padding(.top, DesignTokens.Spacing.xs)
                Text(status.uppercased())
                    .font(Typeface.sans(TypeStyle.Size.micro, weight: .medium))
                    .tracking(TypeStyle.tracking(
                        em: ShellLayout.OnboardingBuild.statusTrackingEm,
                        size: TypeStyle.Size.micro
                    ))
                    .foregroundStyle(Theme.inkMute)
                    .padding(.top, ShellLayout.OnboardingBuild.statusTop)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(ShellLayout.OnboardingBuild.stepPadding)
            .background(shape.fill(isProminent
                    ? Theme.surface
                    : Theme.surface.opacity(ShellLayout.OnboardingBuild.cardDimFill)))
            .elevation(isProminent ? .regular : .small)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
        .disabled(!isOffer)
        .accessibilityLabel("\(name), \(detail), \(status)")
        .accessibilityAddTraits(isTicked ? .isSelected : [])
    }

    @ViewBuilder private var icon: some View {
        let chip = RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.chipRadius, style: .continuous)
        if case let .found(player) = content {
            AppIconImage(path: player.path)
                .frame(width: ShellLayout.OnboardingBuild.chip, height: ShellLayout.OnboardingBuild.chip)
        } else {
            Text(String(name.prefix(1)).uppercased())
                .font(Typeface.display(ShellLayout.OnboardingBuild.chipInitial))
                .foregroundStyle(Theme.ink)
                .frame(width: ShellLayout.OnboardingBuild.chip, height: ShellLayout.OnboardingBuild.chip)
                .background(chip.fill(Theme.cream))
        }
    }

    @ViewBuilder private var marker: some View {
        if isOffer {
            RoundedRectangle(cornerRadius: ShellLayout.OnboardingBuild.tickRadius, style: .continuous)
                .strokeBorder(Theme.ink.opacity(ShellLayout.OnboardingBuild.tickBorderOpacity))
                .frame(width: ShellLayout.OnboardingBuild.tickBox, height: ShellLayout.OnboardingBuild.tickBox)
                .overlay {
                    if isTicked {
                        Image(systemName: "checkmark")
                            .font(.system(size: ShellLayout.OnboardingBuild.tickIcon, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                    }
                }
        } else {
            Image(systemName: "checkmark.circle")
                .font(.system(size: ShellLayout.OnboardingBuild.installedIcon))
                .foregroundStyle(Theme.success)
        }
    }

    private var name: String {
        switch content {
        case let .found(player): player.name
        case let .offer(offer, _): offer.entry.name
        }
    }

    private var detail: String {
        switch content {
        case let .found(player): player.detail
        case let .offer(offer, _): "\(offer.versionLabel) · \(offer.sourceLabel)"
        }
    }

    private var status: String {
        switch content {
        case .found: "Installed"
        case let .offer(_, isTicked): isTicked ? "Will be set up" : "Ready to set up"
        }
    }

    private var isOffer: Bool {
        if case .offer = content {
            return true
        }
        return false
    }

    private var isTicked: Bool {
        if case let .offer(_, isTicked) = content {
            return isTicked
        }
        return false
    }

    private var isProminent: Bool {
        !isOffer || isTicked
    }
}

#Preview {
    let offer = EmulatorOffer(
        entry: ComponentCatalog.bundled().components[0],
        isRecommended: true
    )
    AppearancePreviewPair {
        HStack {
            EmulatorCard(content: .offer(offer, isTicked: true))
            EmulatorCard(content: .offer(offer, isTicked: false))
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
