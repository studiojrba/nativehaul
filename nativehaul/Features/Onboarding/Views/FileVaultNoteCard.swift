import SwiftUI

/// The FileVault trade-off beside the couch choice (TV plan Q4): plain words, the recommendation, the user's choice —
/// it never changes the setting.
struct FileVaultNoteCard: View {
    /// The Mac's real status.
    let status: FileVaultStatus

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: "lock.shield")
                .font(.system(size: ShellLayout.Settings.chipIcon))
                .foregroundStyle(Theme.inkSoft)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(FileVaultNote.title)
                    .font(Typeface.sans(TypeStyle.Size.body, weight: .medium))
                    .foregroundStyle(Theme.ink)
                Text(FileVaultNote.text(for: status))
                    .font(Typeface.sans(TypeStyle.Size.small))
                    .foregroundStyle(Theme.inkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(ShellLayout.OnboardingScenes.notePadding)
        .frostedGlass(in: RoundedRectangle(cornerRadius: KitMetrics.Radius.cover, style: .continuous))
        .elevation(.small)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    AppearancePreviewPair {
        FileVaultNoteCard(status: .on).padding(DesignTokens.Spacing.xl)
    }
}
