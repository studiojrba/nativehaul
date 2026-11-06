import SwiftUI

/// Title of the current Steam setup state.
struct SteamStageHeader: View {
    /// State name.
    let title: String
    /// SF Symbol.
    let symbolName: String

    var body: some View {
        Label(title, systemImage: symbolName).font(DesignTokens.Typography.title)
    }
}

#Preview {
    SteamStageHeader(title: "Ready to sync", symbolName: "checkmark.circle")
        .padding(DesignTokens.Spacing.lg)
}
