import SwiftUI

/// The "Default" / "Make default" pill (spec §3.5 Players): the current default reads on `ink`; the others offer to
/// become it on a quiet `surface` pill.
struct DefaultPlayerPill: View {
    /// Whether this player is the default.
    let isDefault: Bool
    /// Makes it the default.
    let makeDefault: () -> Void

    var body: some View {
        Button(isDefault ? "Default" : "Make default", action: makeDefault)
            .buttonStyle(.plain)
            .font(Typeface.sans(TypeStyle.Size.small))
            .foregroundStyle(isDefault ? Theme.paper : Theme.inkSoft)
            .padding(.horizontal, ShellLayout.Settings.defaultHorizontal)
            .padding(.vertical, ShellLayout.Settings.defaultVertical)
            .background(Capsule().fill(
                isDefault ? Theme.ink : Theme.surface.opacity(KitMetrics.PillButton.surfaceOpacity)
            ))
            .disabled(isDefault)
            .pointerStyle(isDefault ? nil : .link)
            .accessibilityAddTraits(isDefault ? .isSelected : [])
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.md) {
            DefaultPlayerPill(isDefault: true) {}
            DefaultPlayerPill(isDefault: false) {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
