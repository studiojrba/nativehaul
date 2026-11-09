import SwiftUI

/// Flags the games the Installed filter can't place (ADR 0036): a labelled group with a Show/Hide button, so they
/// never vanish silently.
struct UnknownInstallHeader: View {
    /// How many games have no install record.
    let count: Int
    /// Whether the group is showing.
    @Binding var isShowing: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: "Can't tell if installed", caption: "no install record from any source")
            Spacer()
            Button(isShowing ? "Hide \(count)" : "Show \(count)") { isShowing.toggle() }
                .font(DesignTokens.Typography.monospacedSmall)
        }
    }
}

#Preview {
    UnknownInstallHeader(count: 4, isShowing: .constant(false))
        .padding(DesignTokens.Spacing.xl)
}
