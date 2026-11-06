import SwiftUI

/// The app's Settings window. Each feature contributes a tab.
struct SettingsView: View {
    /// App dependencies.
    let environment: AppEnvironment

    var body: some View {
        TabView {
            SteamSettingsView(viewModel: environment.makeSteamSettingsViewModel())
                .tabItem { Label("Steam", systemImage: "cloud") }
        }
        .frame(minWidth: DesignTokens.Layout.detailMinWidth, minHeight: DesignTokens.Layout.logMinHeight)
        .padding(DesignTokens.Spacing.lg)
    }
}

#Preview {
    SettingsView(environment: .preview)
}
