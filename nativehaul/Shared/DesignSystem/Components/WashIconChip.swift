import SwiftUI

/// A rounded chip filled with a wash, holding an SF Symbol (spec §3.5 group icons).
struct WashIconChip: View {
    /// The SF Symbol.
    let symbolName: String
    /// The wash behind it.
    let slot: WashSlot
    /// Chip side.
    var size: CGFloat = ShellLayout.Settings.chipSize
    /// Corner radius.
    var radius: CGFloat = ShellLayout.Settings.chipRadius
    /// Glyph size.
    var iconSize: CGFloat = ShellLayout.Settings.chipIcon

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: iconSize))
            .foregroundStyle(Theme.ink)
            .frame(width: size, height: size)
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(Theme.wash(slot)))
            .accessibilityHidden(true)
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: DesignTokens.Spacing.md) {
            WashIconChip(symbolName: "circle.lefthalf.filled", slot: .cream)
            WashIconChip(symbolName: "folder", slot: .butter)
            WashIconChip(symbolName: "key", slot: .blush)
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
