import SwiftUI

/// The app's Settings window. Each feature contributes a tab.
struct SettingsView: View {
    /// App dependencies.
    let environment: AppEnvironment

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
            SteamSettingsView(viewModel: environment.makeSteamConnectionViewModel())
                .tabItem { Label("Steam", systemImage: "cloud") }
            ArtworkSettingsView(viewModel: environment.makeArtworkSettingsViewModel())
                .tabItem { Label("Artwork", systemImage: "photo.on.rectangle") }
            GameFoldersSettingsView(viewModel: environment.makeGameFoldersViewModel())
                .tabItem { Label("Game Folders", systemImage: "folder") }
            EmulatorSettingsView(viewModel: environment.makeEmulatorSettingsViewModel())
                .tabItem { Label("Emulators", systemImage: "arcade.stick") }
            TrackingSettingsView(viewModel: environment.makeTrackingSettingsViewModel())
                .tabItem { Label("Tracking", systemImage: "timer") }
            NXNativeSettingsView(viewModel: environment.makeNXNativeSettingsViewModel())
                .tabItem { Label("NXNative", systemImage: "hammer") }
        }
        .frame(minWidth: DesignTokens.Layout.detailMinWidth, minHeight: DesignTokens.Layout.logMinHeight)
        .padding(DesignTokens.Spacing.lg)
    }
}

#Preview {
    SettingsView(environment: .preview)
}
