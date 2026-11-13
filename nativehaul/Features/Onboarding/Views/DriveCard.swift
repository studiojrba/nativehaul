import SwiftUI

/// One drive in the install scene (spec §3.6 "Disk"): its real name, where builds would go, a usage bar and the real
/// free space. The chosen drive sits forward; the other steps back.
struct DriveCard: View {
    /// The volume.
    let volume: VolumeInfo
    /// Where builds go on it.
    let path: String
    /// Whether it's the one in use (or hovered).
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WashIconChip(
                symbolName: "externaldrive",
                slot: .sky,
                size: ShellLayout.OnboardingScenes.diskChip,
                radius: KitMetrics.Radius.bar,
                iconSize: ShellLayout.OnboardingScenes.diskIcon
            )
            Text(volume.name)
                .font(Typeface.sans(ShellLayout.OnboardingScenes.diskName, weight: .medium))
                .foregroundStyle(Theme.ink)
                .padding(.top, ShellLayout.OnboardingScenes.diskNameTop)
            Text(OnboardingScript.abbreviate(path))
                .font(.system(size: TypeStyle.Size.caption, design: .monospaced))
                .foregroundStyle(Theme.inkMute)
                .lineLimit(DesignTokens.Lines.single)
                .truncationMode(.middle)
                .padding(.top, DesignTokens.Spacing.xs)
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.paper2)
                    Capsule().fill(Theme.ink).frame(width: proxy.size.width * volume.usedFraction)
                }
            }
            .frame(height: ShellLayout.OnboardingScenes.usageHeight)
            .padding(.top, ShellLayout.OnboardingScenes.diskNameTop)
            Text("\(volume.freeGigabytes) GB free")
                .font(Typeface.sans(TypeStyle.Size.small))
                .foregroundStyle(Theme.inkSoft)
                .padding(.top, DesignTokens.Spacing.sm)
        }
        .padding(ShellLayout.OnboardingScenes.diskPadding)
        .background(
            RoundedRectangle(cornerRadius: KitMetrics.Radius.panel, style: .continuous)
                .fill(Theme.surface.opacity(isSelected ? 1 : ShellLayout.OnboardingScenes.diskDimFill))
        )
        .elevation(isSelected ? .large : .small)
        .scaleEffect(isSelected ? 1 : ShellLayout.OnboardingScenes.diskDimScale)
        .opacity(isSelected ? 1 : ShellLayout.OnboardingScenes.diskDimOpacity)
        .animation(Motion.settle(Motion.Duration.rise), value: isSelected)
    }
}

#Preview {
    AppearancePreviewPair {
        if let volume = MockVolumeInspector.preview.startup {
            DriveCard(volume: volume, path: "~/Switch/Games", isSelected: true).padding(DesignTokens.Spacing.xl)
        }
    }
}
