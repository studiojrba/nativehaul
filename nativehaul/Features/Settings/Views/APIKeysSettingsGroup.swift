import SwiftUI

/// Settings → API keys (spec §1.2, §3.5): the only credentials in the app — SteamGridDB, IGDB (client ID + secret) and
/// RetroAchievements (username + key). Keys go only to the Keychain; fields always start empty, a stored key shows as
/// **Saved**, and typing a new one replaces it. Every key is optional: the app works fully without them.
struct APIKeysSettingsGroup: View {
    /// SteamGridDB.
    @Bindable var steamGridDB: ArtworkSettingsViewModel
    /// IGDB.
    @Bindable var igdb: IGDBSettingsViewModel
    /// RetroAchievements.
    @Bindable var retroAchievements: RetroAchievementsSettingsViewModel

    var body: some View {
        SettingsGroup(
            symbolName: "key",
            tint: .blush,
            title: "API keys",
            note: "Optional. Nicer artwork and game info."
        ) {
            keyRow(
                "SteamGridDB",
                sub: "Box art and hero images",
                isSaved: steamGridDB.hasKey,
                error: steamGridDB.isError ? steamGridDB.statusMessage : nil,
                remove: steamGridDB.removeKey
            ) {
                APIKeyField(text: $steamGridDB.keyInput, canSave: steamGridDB.canSave, save: steamGridDB.save)
            }
            keyRow(
                "IGDB client ID",
                sub: "Descriptions, studios, release years",
                isSaved: igdb.hasCredentials,
                error: igdb.isError ? igdb.statusMessage : nil,
                remove: igdb.remove
            ) {
                APIKeyField(text: $igdb.clientIDInput, canSave: igdb.canSave, save: igdb.save)
            }
            keyRow("IGDB client secret", sub: "Pairs with the client ID", isSaved: igdb.hasCredentials) {
                APIKeyField(text: $igdb.clientSecretInput, canSave: igdb.canSave, save: igdb.save)
            }
            keyRow(
                "RetroAchievements username",
                sub: "Achievements for your emulated games",
                isSaved: retroAchievements.hasCredentials,
                error: retroAchievements.isError ? retroAchievements.statusMessage : nil,
                remove: retroAchievements.remove
            ) {
                APIKeyField(
                    text: $retroAchievements.usernameInput,
                    placeholder: "Your username",
                    canSave: retroAchievements.canSave,
                    save: retroAchievements.save
                )
            }
            keyRow(
                "RetroAchievements key",
                sub: "Pairs with your username",
                isSaved: retroAchievements.hasCredentials
            ) {
                APIKeyField(
                    text: $retroAchievements.apiKeyInput,
                    canSave: retroAchievements.canSave,
                    save: retroAchievements.save
                )
            }
        }
        .task {
            await steamGridDB.refresh()
            await igdb.refresh()
            await retroAchievements.refresh()
        }
    }

    private func keyRow(
        _ label: String,
        sub: String,
        isSaved: Bool,
        error: String? = nil,
        remove: (() -> Void)? = nil,
        @ViewBuilder field: () -> some View
    ) -> some View {
        let input = field()
        return SettingsRow(label: label, sub: sub, badge: isSaved ? "Saved" : nil, footnote: error) {
            HStack(spacing: ShellLayout.Settings.controlGap) {
                if isSaved, let remove {
                    QuietTextButton(title: "Remove", action: remove)
                }
                input
            }
        }
    }
}

#Preview {
    AppearancePreviewPair {
        APIKeysSettingsGroup(
            steamGridDB: ArtworkSettingsViewModel(store: MockSteamGridDBKeyStore(hasKey: true)),
            igdb: IGDBSettingsViewModel(store: MockIGDBCredentialStore()),
            retroAchievements: RetroAchievementsSettingsViewModel(store: MockRetroAchievementsCredentialStore())
        )
        .padding(DesignTokens.Spacing.xl)
    }
}
