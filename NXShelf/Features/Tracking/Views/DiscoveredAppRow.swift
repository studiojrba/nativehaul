import SwiftUI

/// An untracked `.app` found in the games folder.
struct DiscoveredAppRow: View {
    /// The app.
    let app: DiscoveredApp
    /// Called when the user taps Track.
    let onTrack: () -> Void

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(app.name).font(DesignTokens.Typography.headline)
                Text(app.path)
                    .font(DesignTokens.Typography.monospacedSmall)
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(DesignTokens.Lines.single)
                    .truncationMode(.middle)
            }
            Spacer(minLength: DesignTokens.Spacing.none)
            Button("Track", action: onTrack)
        }
    }
}

#Preview {
    DiscoveredAppRow(app: DiscoveredApp(name: "Tideborn", path: "/Users/demo/Switch/Games/Tideborn.app")) {}
        .padding(DesignTokens.Spacing.lg)
}
