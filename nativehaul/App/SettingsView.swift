import SwiftUI

/// The app's Settings window. Each feature contributes a tab.
struct SettingsView: View {
    /// App dependencies.
    let environment: AppEnvironment

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
            RetroAchievementsSettingsView(viewModel: environment.makeRetroAchievementsSettingsViewModel())
                .tabItem { Label("RetroAchievements", systemImage: "trophy") }
            ArtworkSettingsView(
                viewModel: environment.makeArtworkSettingsViewModel(),
                igdbViewModel: environment.makeIGDBSettingsViewModel()
            )
            .tabItem { Label("Artwork", systemImage: "photo.on.rectangle") }
            GameFoldersSettingsView(viewModel: environment.makeGameFoldersViewModel())
                .tabItem { Label("Game Folders", systemImage: "folder") }
            EmulatorSettingsView(viewModel: environment.makeEmulatorSettingsViewModel())
                .tabItem { Label("Emulators", systemImage: "arcade.stick") }
            UpdatesSettingsView(viewModel: environment.makeUpdatesSettingsViewModel())
                .tabItem { Label("Updates", systemImage: "arrow.down.circle") }
            TVModeSettingsView(viewModel: environment.makeTVModeSettingsViewModel())
                .tabItem { Label("TV Mode", systemImage: "tv") }
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
