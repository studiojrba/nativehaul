import SwiftUI

/// The frost pill on a Library cover when a game isn't simply ready (spec §3.2): "Building…" or "Update ready".
struct LibraryBadgePill: View {
    /// The badge.
    let badge: LibraryBuildBadge

    var body: some View {
        FrostPill {
            Text(badge.label)
                .font(Typeface.sans(TypeStyle.Size.micro, weight: .medium))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, ShellLayout.Library.badgeHorizontal)
                .padding(.vertical, ShellLayout.Library.badgeVertical)
        }
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.md) {
            LibraryBadgePill(badge: .building)
            LibraryBadgePill(badge: .updateReady)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
