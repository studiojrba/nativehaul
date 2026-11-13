import SwiftUI

/// "Back to the shelf" (spec §3.3): a `surface` 60% pill with an arrow, returning to the screen Detail was opened from.
struct BackToShelfPill: View {
    /// Goes back.
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "arrow.left")
                    .font(.system(size: ShellLayout.Chrome.backArrow))
                Text("Back to the shelf")
                    .font(Typeface.sans(TypeStyle.Size.small))
            }
            .foregroundStyle(Theme.inkSoft)
            .padding(.horizontal, KitMetrics.Frost.pillHorizontal)
            .padding(.vertical, KitMetrics.Frost.pillVertical)
            .background(Capsule().fill(Theme.surface.opacity(ShellLayout.Chrome.backFillOpacity)))
            .elevation(.small)
            .contentShape(Capsule())
        }
        .buttonStyle(PressButtonStyle())
        .keyboardShortcut("[", modifiers: .command)
    }
}

#Preview {
    AppearancePreviewPair {
        BackToShelfPill {}.padding(DesignTokens.Spacing.xl)
    }
}
