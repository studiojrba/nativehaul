import SwiftUI

/// The app's Settings window. Each feature contributes a tab.
struct SettingsView: View {
    /// App dependencies.
    let environment: AppEnvironment
    @State private var tab = SettingsTab.general

    var body: some View {
        TabView(selection: $tab) {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }.tag(SettingsTab.general)
            SteamSettingsView(viewModel: environment.makeSteamConnectionViewModel())
                .tabItem { Label("Steam", systemImage: "cloud") }.tag(SettingsTab.steam)
            ArtworkSettingsView(
                viewModel: environment.makeArtworkSettingsViewModel(),
                igdbViewModel: environment.makeIGDBSettingsViewModel()
            )
            .tabItem { Label("Artwork", systemImage: "photo.on.rectangle") }.tag(SettingsTab.artwork)
            GameFoldersSettingsView(viewModel: environment.makeGameFoldersViewModel())
                .tabItem { Label("Game Folders", systemImage: "folder") }.tag(SettingsTab.gameFolders)
            EmulatorSettingsView(viewModel: environment.makeEmulatorSettingsViewModel())
                .tabItem { Label("Emulators", systemImage: "arcade.stick") }.tag(SettingsTab.emulators)
            UpdatesSettingsView(viewModel: environment.makeUpdatesSettingsViewModel())
                .tabItem { Label("Updates", systemImage: "arrow.down.circle") }.tag(SettingsTab.updates)
            TrackingSettingsView(viewModel: environment.makeTrackingSettingsViewModel())
                .tabItem { Label("Tracking", systemImage: "timer") }.tag(SettingsTab.tracking)
            NXNativeSettingsView(viewModel: environment.makeNXNativeSettingsViewModel())
                .tabItem { Label("NXNative", systemImage: "hammer") }.tag(SettingsTab.nxnative)
        }
        .frame(minWidth: DesignTokens.Layout.detailMinWidth, minHeight: DesignTokens.Layout.logMinHeight)
        .padding(DesignTokens.Spacing.lg)
        .environment(\.onboardingGuide, environment.guide)
        .overlay(alignment: .bottom) {
            // The tour's Steam step happens here, in the real place (ADR 0040).
            if environment.guide.currentStep == .steam {
                GuideBubble(guide: environment.guide, step: .steam).padding(DesignTokens.Spacing.lg)
            }
        }
        .onChange(of: environment.guide.currentStep, initial: true) { _, step in
            if step == .steam {
                tab = .steam
            }
        }
    }
}

#Preview {
    SettingsView(environment: .preview)
}
