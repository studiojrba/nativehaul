import SwiftUI

/// The one-time offer to set up Steam in CrossOver, in J.R's words.
struct GoldenBottleOfferView: View {
    /// Why the golden bottle isn't ready.
    let status: GoldenBottleStatus
    /// Accepts the offer.
    let onAccept: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            switch status {
            case .steamNotLinked:
                Text("Sign in through Steam first, on the Steam screen. Then Windows games can install here with "
                    + "one click.")
            case .notSetUp, .foundButNotLean:
                Text("Would you like to install Steam via CrossOver? From there, I can install games for you in here "
                    + "directly — one game per bottle, each with its own perfect, community-proven settings.")
                if case let .foundButNotLean(name) = status {
                    Text("“\(name)” is already signed in, but it has games installed, so copying it for every game "
                        + "would copy them too. A separate, empty one keeps each game's bottle small.")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
                Button("Install Steam via CrossOver", systemImage: "arrow.down.app", action: onAccept)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                Text("You'll sign in to Steam once, in Steam's own window. NX Shelf never sees your password.")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(Theme.secondaryText)
            case .crossOverMissing, .ready:
                EmptyView()
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    GoldenBottleOfferView(status: .notSetUp) {}
        .frame(width: DesignTokens.Details.rightRailWidth)
        .padding(DesignTokens.Spacing.lg)
}
