import SwiftUI

/// The frosted pill under the case (spec §3.3): a rotate icon, "Turn it over" or "Flip to the front", and a muted
/// "· or drag it · {playtime} played".
struct CaseTurnButton: View {
    /// Whether the case shows its back.
    let isShowingBack: Bool
    /// The muted suffix.
    let hint: String
    /// Turns the case a half turn.
    let action: () -> Void

    private typealias Metrics = ShellLayout.GameCase

    var body: some View {
        Button(action: action) {
            HStack(spacing: Metrics.buttonGap) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: Metrics.buttonIcon))
                Text(isShowingBack ? "Flip to the front" : "Turn it over")
                Text(hint).foregroundStyle(Theme.inkMute)
            }
            .font(Typeface.sans(TypeStyle.Size.small))
            .foregroundStyle(Theme.inkSoft)
            .lineLimit(1)
            .padding(.horizontal, Metrics.buttonHorizontal)
            .padding(.vertical, Metrics.buttonVertical)
            .frostedGlass(in: Capsule())
            .elevation(.small)
        }
        .buttonStyle(PressButtonStyle())
    }
}

#Preview {
    AppearancePreviewPair {
        VStack(spacing: DesignTokens.Spacing.lg) {
            CaseTurnButton(isShowingBack: false, hint: "· or drag it · 11h 40m played") {}
            CaseTurnButton(isShowingBack: true, hint: "· or drag it") {}
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
