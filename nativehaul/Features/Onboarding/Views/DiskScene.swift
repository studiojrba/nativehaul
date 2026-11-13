import SwiftUI

/// The install scene (spec §3.6 "Disk"): this Mac's real drive, and an external drive only when one is mounted.
/// Hovering "Use my external drive" brings that card forward.
struct DiskScene: View {
    /// The real state.
    let facts: OnboardingFacts
    /// The hovered action.
    let hovered: OnboardingAction?

    var body: some View {
        HStack(alignment: .top, spacing: ShellLayout.OnboardingScenes.diskGap) {
            if let volume = facts.installVolume {
                DriveCard(
                    volume: volume,
                    path: facts.usesExternal ? volume.mountPath : facts.installLocation,
                    isSelected: !external
                )
            }
            if let drive = facts.externalVolume {
                DriveCard(volume: drive, path: drive.installFolder, isSelected: external)
            }
        }
        .frame(maxWidth: ShellLayout.OnboardingScenes.diskMaxWidth)
    }

    private var external: Bool {
        if case .useExternal = hovered?.effect {
            return true
        }
        return facts.usesExternal
    }
}

#Preview {
    var facts = OnboardingFacts()
    facts.installLocation = "~/Switch/Games"
    facts.installVolume = MockVolumeInspector.preview.startup
    return AppearancePreviewPair {
        DiskScene(facts: facts, hovered: nil).padding(DesignTokens.Spacing.xl)
    }
}
