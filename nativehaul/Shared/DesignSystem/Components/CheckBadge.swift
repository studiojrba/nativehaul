import SwiftUI

/// The small mint badge with a check (spec §3.5 "Valid" and "Saved"): mint wash fill, `ok` text, 11pt medium.
struct CheckBadge: View {
    /// The badge text.
    let text: String

    var body: some View {
        HStack(spacing: ShellLayout.Settings.badgeInnerGap) {
            Image(systemName: "checkmark")
                .font(.system(size: ShellLayout.Settings.badgeIcon, weight: .semibold))
            Text(text)
        }
        .font(Typeface.sans(TypeStyle.Size.micro, weight: .medium))
        .foregroundStyle(Theme.success)
        .padding(.horizontal, ShellLayout.Settings.badgeHorizontal)
        .padding(.vertical, ShellLayout.Settings.badgeVertical)
        .background(Capsule().fill(Theme.wash(.mint)))
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.md) {
            CheckBadge(text: "Valid")
            CheckBadge(text: "Saved")
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
