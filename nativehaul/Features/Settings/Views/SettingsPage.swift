import SwiftUI

/// Settings (spec §3.5), one in-window page: "The back room" header, then Appearance, Audio, Directories, Players, API
/// keys, Couch mode and Behind the scenes, the replay-tour card and the footer with the real version. Opened from the
/// nav island and from ⌘, (ADR 0057). No sign-ins anywhere.
struct SettingsPage: View {
    /// App dependencies.
    let environment: AppEnvironment
    @State private var directories: DirectoriesSettingsViewModel
    @State private var players: PlayersSettingsViewModel
    @State private var steamGridDB: ArtworkSettingsViewModel
    @State private var igdb: IGDBSettingsViewModel
    @State private var retroAchievements: RetroAchievementsSettingsViewModel
    @State private var couch: CouchSettingsViewModel
    @State private var updates: UpdatesSettingsViewModel
    @State private var width: CGFloat = ShellLayout.Content.maxWidth

    /// Creates the page.
    init(environment: AppEnvironment) {
        self.environment = environment
        _directories = State(initialValue: environment.makeDirectoriesSettingsViewModel())
        _players = State(initialValue: environment.makePlayersSettingsViewModel())
        _steamGridDB = State(initialValue: environment.makeArtworkSettingsViewModel())
        _igdb = State(initialValue: environment.makeIGDBSettingsViewModel())
        _retroAchievements = State(initialValue: environment.makeRetroAchievementsSettingsViewModel())
        _couch = State(initialValue: CouchSettingsViewModel(store: environment.modePreferences))
        _updates = State(initialValue: environment.makeUpdatesSettingsViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                AppearanceSettingsGroup(controller: environment.appearance)
                AudioSettingsGroup(controller: environment.audio)
                DirectoriesSettingsGroup(viewModel: directories)
                PlayersSettingsGroup(viewModel: players)
                APIKeysSettingsGroup(steamGridDB: steamGridDB, igdb: igdb, retroAchievements: retroAchievements)
                CouchSettingsGroup(viewModel: couch)
                BehindTheScenesGroup(environment: environment, updates: updates)
                ReplayTourCard { OnboardingRequest.post() }
                Text(SettingsCopy.footer(version: AppInfo.version))
                    .font(Typeface.sans(TypeStyle.Size.small))
                    .foregroundStyle(Theme.inkMute)
                    .frame(maxWidth: .infinity)
                    .padding(.top, ShellLayout.Settings.footerTop)
            }
            .frame(maxWidth: ShellLayout.Settings.maxWidth)
            .padding(.leading, ShellLayout.Settings.leadingPadding)
            .padding(.trailing, ShellLayout.Settings.trailingPadding)
            .padding(.top, ShellLayout.Settings.topPadding)
            .padding(.bottom, ShellLayout.Settings.bottomPadding)
            .frame(maxWidth: .infinity)
            .background(alignment: .top) {
                WashBackground(slots: [.sky, .butter])
                    .frame(height: ShellLayout.Settings.washHeight)
            }
        }
        .scrollIndicators(.never)
        .onGeometryChange(for: CGFloat.self, of: \.size.width) { width = $0 }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Eyebrow("Settings")
            DisplayHeadline(
                lead: "The back room",
                size: TypeStyle.clampedDisplay(
                    width: width,
                    min: ShellLayout.Settings.titleMin,
                    share: ShellLayout.Settings.titleWidthShare,
                    max: ShellLayout.Settings.titleMax
                ),
                lineHeight: ShellLayout.Settings.titleLineHeight
            )
            .padding(.top, ShellLayout.Settings.titleTop)
            Text(SettingsCopy.intro)
                .font(Typeface.sans(TypeStyle.Size.lead))
                .foregroundStyle(Theme.inkSoft)
                .lineSpacing(TypeStyle.leadLineSpacing)
                .frame(maxWidth: ShellLayout.Settings.introMaxWidth, alignment: .leading)
                .padding(.top, ShellLayout.Settings.introTop)
        }
        .riseIn()
    }
}

#Preview {
    SettingsPage(environment: .preview)
        .frame(width: ShellLayout.Content.maxWidth, height: DesignTokens.Layout.windowMinHeight)
}
