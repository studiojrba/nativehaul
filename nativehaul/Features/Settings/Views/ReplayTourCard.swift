import SwiftUI

/// "Take the welcome tour again" (spec §3.5): replays onboarding without resetting anything — not the folders, not the
/// keys, not the appearance.
struct ReplayTourCard: View {
    /// Starts the tour.
    let replay: () -> Void

    var body: some View {
        Button(action: replay) {
            HStack(spacing: ShellLayout.Settings.replayGap) {
                Image(systemName: "sparkles")
                    .font(.system(size: ShellLayout.Settings.replayIcon))
                    .foregroundStyle(Theme.ink)
                    .frame(width: ShellLayout.Settings.replayChip, height: ShellLayout.Settings.replayChip)
                    .background(Circle().fill(Theme.surface))
                    .elevation(.small)
                VStack(alignment: .leading, spacing: ShellLayout.Settings.subTop) {
                    Text("Take the welcome tour again")
                        .font(Typeface.sans(TypeStyle.Size.callout, weight: .medium))
                        .foregroundStyle(Theme.ink)
                    Text("Same friendly chat, same questions. Nothing gets reset.")
                        .font(Typeface.sans(TypeStyle.Size.body))
                        .foregroundStyle(Theme.inkSoft)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, ShellLayout.Settings.replayHorizontal)
            .padding(.vertical, ShellLayout.Settings.replayVertical)
            .background(
                RoundedRectangle(cornerRadius: KitMetrics.Radius.panel, style: .continuous)
                    .fill(Theme.cream.opacity(ShellLayout.Settings.replayOpacity))
            )
            .elevation(.small)
            .contentShape(RoundedRectangle(cornerRadius: KitMetrics.Radius.panel, style: .continuous))
        }
        .buttonStyle(PressButtonStyle())
        .padding(.top, ShellLayout.Settings.replayTop)
    }
}

#Preview {
    AppearancePreviewPair {
        ReplayTourCard {}.padding(DesignTokens.Spacing.xl)
    }
}
