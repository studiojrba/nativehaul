import SwiftUI

/// The round favourite button (spec §3.3): 56pt, `surface` 70%, `elev-sm`, a heart that fills with the accent when on.
struct FavoriteToggleButton: View {
    /// Whether the game is a favourite.
    let isOn: Bool
    /// Toggles it.
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .font(.system(size: ShellLayout.Detail.heartSize))
                .foregroundStyle(isOn ? Theme.accent : Theme.ink)
                .frame(width: ShellLayout.Detail.favouriteSize, height: ShellLayout.Detail.favouriteSize)
                .background {
                    Circle().fill(.ultraThinMaterial)
                    Circle().fill(Theme.surface.opacity(KitMetrics.PillButton.surfaceOpacity))
                }
                .elevation(.small)
                .contentShape(Circle())
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityLabel(isOn ? "Remove from favourites" : "Add to favourites")
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.lg) {
            FavoriteToggleButton(isOn: false) {}
            FavoriteToggleButton(isOn: true) {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
