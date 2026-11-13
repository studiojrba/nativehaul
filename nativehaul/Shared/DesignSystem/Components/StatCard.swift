import SwiftUI

/// A frosted stat card (spec §3.4): a 12pt `ink-mute` label over a 16pt value, radius 24, `elev-sm`.
struct StatCard: View {
    /// The label.
    let label: String
    /// The value.
    let value: String

    var body: some View {
        FrostPill(cornerRadius: ShellLayout.Builds.statRadius) {
            VStack(alignment: .leading, spacing: ShellLayout.Builds.statValueTop) {
                Text(label)
                    .font(Typeface.sans(TypeStyle.Size.caption))
                    .foregroundStyle(Theme.inkMute)
                Text(value)
                    .font(Typeface.sans(TypeStyle.Size.callout))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(DesignTokens.Typography.minimumScale)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, ShellLayout.Builds.statHorizontal)
            .padding(.vertical, ShellLayout.Builds.statVertical)
        }
    }
}

#Preview {
    AppearancePreviewPair {
        HStack(spacing: ShellLayout.Builds.statsGap) {
            StatCard(label: "Stage", value: "Shaders")
            StatCard(label: "Time left", value: "5:10")
        }
        .padding(DesignTokens.Spacing.xl)
    }
}
